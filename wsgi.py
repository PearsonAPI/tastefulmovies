from gevent import monkey; monkey.patch_all()
import sys
import os

# Add ./vendor to path
sys.path = [os.path.dirname(os.path.abspath(__file__)) + '/vendor'] + sys.path

# Export WSGI app
from glu import create_app
application = create_app(config='prod')
