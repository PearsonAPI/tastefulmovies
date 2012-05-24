from flask import request, session, abort, redirect

from glu import cache
from . import helpers
from . import api

import hashlib
import json
import time
import nltk

@api.route('/autocomplete')
@helpers.jsonify
def autocomplete():
  query = request.args.get('q', None)
  return {'results': helpers.autocomplete(query, 10)}

@api.route('/search')
@helpers.jsonify
def search():
  def cache_result(result):
    cache.set('rcp:%s' % result['id'], json.dumps(result))

  def parse_result(result):
    # cache the raw result, with its full ingredient list, etc.
    cache_result(result)

    output = {'id': result['id'], 'name': result['name']}

    if 'cuisine' in result:
      output['cuisine'] = result['cuisine']

    if 'image' in result:
      output['image'] = result['image']

    return output

  query = request.args.get('q', None).split(',')
  results = [parse_result(result) for result in helpers.pearson(*query)['results']]
  return {'results': results}

@api.route('/associate')
@helpers.jsonify
def associate():
  query = request.args.get('q', None)
  response = {'results': [], 'recipe': None}

  if not query:
    return response

  recipe = json.loads(cache.get('rcp:%s' % query))

  if not recipe: 
    return response

  response['recipe'] = recipe
  stopwords = set(nltk.corpus.stopwords.words('english'))
  tokens = nltk.tokenize.word_tokenize(recipe['name'])
  tokens.append(recipe['cuisine'])
  tokens = [word.lower() for word in tokens if not word in stopwords] 
  results = helpers.netflix('/catalog/titles', {'term': '|'.join(tokens)})

  if 'catalog_titles' in results and 'catalog_title' in results['catalog_titles']:
    results = filter(lambda x: 'average_rating' in x, results['catalog_titles']['catalog_title'])
    #results = sorted(results, key=lambda x: x['average_rating'])
    #results.reverse()
    response['results'] = results
  else:
    response['results'] = results

  response['query'] = recipe
  return response

