from flask import Flask

import hashlib
import json
import redis

# a global cache object to be assigned during application start-up, @see create_app.
# since functions spawned by gevent may require access to the cache, and at that time,
# the current flask application is not in scope, we preserve an active, global cache
# at application start-up.
cache = None

def create_app(config=None):
  config = 'dev' if config is None else config

  app = Flask(__name__)
  app.config.from_object('glu.config.' + config)

  # Static content
  app.static_folder = app.config.get('STATIC_DIR', 'assets')

  # Use pyjade templates
  app.jinja_env.add_extension('pyjade.ext.jinja.PyJadeExtension')

  # Cache
  global cache
  cache = redis.Redis(
      host=app.config['REDIS_HOST'],
      port=app.config['REDIS_PORT'])

  from glu.views.api import api
  from glu.views.site import site

  app.register_blueprint(site)
  app.register_blueprint(api, url_prefix='/api')

  return app

def bootstrap_app(app, delete_existing=False):
  print 'Bootstrapping application [%s]..' % app

  if delete_existing:
    cache.flushdb()

  with open('data/ingredients.txt') as f:  
    for line in f:
      cache.set('ing:%s' % line)

  print 'Bootstrap complete'

