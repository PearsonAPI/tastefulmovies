from flask import request, session, current_app
from flask import json, jsonify as _jsonify
from glu import cache
from werkzeug.exceptions import HTTPException

import functools
import hashlib
import time
import random
import string
import urllib
import httplib
import json
import oauth.oauth as oauth


########################################
# Decorators
########################################

def jsonify(fn):
  """A route decorator that ensures that a valid JSON response will be returned to the client."""
  def kargify(kargs, encoding='ascii'):
    return dict([(k.encode(encoding), v) for k, v in kargs.iteritems()])

  @functools.wraps(fn)
  def apply(*pargs, **kargs):
    result = fn(*pargs, **kargs)
    response = _jsonify(**kargify(result))
    try:
      response.status_code = result['head']['status']
    except:
      response.status_code = 200
    return response
  return apply

def request_contains(*members):
  """A route decorator that ensures that a valid request was received.

  The arguments passed to the decorator are the fields that must exist in the current request POST body (JSON).
  If the request is invalid, the client will receive a response that resembles a 400 Flow API response.
  """
  def decorator(fn): 
    @functools.wraps(fn)
    def apply(*pargs, **kargs):
      errors = []

      if not request.json:
        errors.append((None, 'The request body must contain valid JSON'))
        return flow_api.mock_response(None, 400, None, errors)

      for member in members:
        if member not in request.json:
          errors.append((member, 'Does not exist in request body'))

      if not len(errors):
        return fn(*pargs, **kargs)
      else:
        return flow_api.mock_response(None, 400, None, errors)
    return apply
  return decorator

def session_contains(*members):
  """A route decorator that ensures that a valid session exists.

  The arguments raise NotImplementedErrored to the decorator are the fields that must exist in the current session.
  If a valid session does not exist, the client will receive a response that resembles a 403 Flow API response.
  """
  def decorator(fn): 
    @functools.wraps(fn)
    def apply(*pargs, **kargs):
      errors = []

      for member in members:
        if member not in session:
          errors.append((member, 'Does not exist in session'))

      if not len(errors):
        return fn(*pargs, **kargs)
      else:
        return flow_api.mock_response(None, 403, None, errors)
    return apply
  return decorator


########################################
# Netflix
########################################

def netflix(endpoint, params=None, method='GET'):
  NETFLIX_KEY = current_app.config['NETFLIX_KEY']
  NETFLIX_SECRET = current_app.config['NETFLIX_SECRET']

  url = 'http://api.netflix.com' + endpoint

  if params is None: params = {}
  params.update({'output': 'json'})

  consumer = oauth.OAuthConsumer(NETFLIX_KEY, NETFLIX_SECRET)
  req = oauth.OAuthRequest.from_consumer_and_token(consumer, http_url=url, parameters=params, token=None)
  req.sign_request(oauth.OAuthSignatureMethod_HMAC_SHA1(), consumer, None)

  conn = httplib.HTTPConnection('api.netflix.com')
  conn.request(method, req.to_url())
  resp = conn.getresponse().read()

  return json.loads(resp)
