from flask import request, session, abort, redirect

from glu import cache
from . import helpers
from . import api

import json
import time
import nltk
import urllib

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
  response = {'results': []}

  if not query:
    return response

  serialized_recipe = cache.get('rcp:%s' % query)

  if not serialized_recipe:
    return response

  partial_recipe = json.loads(serialized_recipe)
  full_recipe = json.loads(urllib.urlopen(partial_recipe['url']).read())

  stopwords = set(nltk.corpus.stopwords.words('english'))
  tokens = nltk.tokenize.word_tokenize(full_recipe['name'])

  if full_recipe['cuisine'] != 'N/A':
    tokens.append(full_recipe['cuisine'])

  tokens = [word.lower() for word in tokens if not word in stopwords] 
  results = helpers.netflix('/catalog/titles', {'term': ' '.join(tokens)})

  if 'catalog_titles' in results and 'catalog_title' in results['catalog_titles']:
    results = filter(lambda x: 'average_rating' in x, results['catalog_titles']['catalog_title'])
    response['results'] = results
  else:
    response['results'] = results

  response['query'] = full_recipe
  return response

