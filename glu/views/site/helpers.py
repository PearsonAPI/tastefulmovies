from flask import current_app, request, Response

import functools


def requires_authorization(fn):
  @functools.wraps(fn)
  def apply(*args, **kwargs):
    admin_username = current_app.config['ADMIN_USERNAME']
    admin_password = current_app.config['ADMIN_PASSWORD']

    authorization = request.authorization
    is_authorized = lambda username, password: username == admin_username and password == admin_password

    if not authorization or not is_authorized(authorization.username, authorization.password):
      return Response('Access denied', 401, {'WWW-Authenticate': 'Basic realm="Login Required"'})

    return fn(*args, **kwargs)
  return apply

