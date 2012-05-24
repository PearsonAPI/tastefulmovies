import sys
import os

from flask import current_app
from flask.ext.script import Server, Manager
from glu import create_app

# Init manager
manager = Manager(create_app)

# Add option for specifying a config
manager.add_option('-c', '--config', dest='config', required=False)

# Add option for starting up a test server
manager.add_command('runserver', Server(threaded=True))

# Run cli
if __name__ == '__main__':
  manager.run()
