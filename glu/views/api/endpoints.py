from flask import request, session, abort, redirect

from . import helpers
from . import api

import hashlib
import json
import time

@api.route('/autocomplete')
@helpers.jsonify
def autocomplete():
  query = request.args.get('q', None)
  return {'results': helpers.autocomplete(query, 10)}

