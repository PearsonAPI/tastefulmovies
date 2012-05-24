import datetime
import hashlib
import json
from time import time

from flask import current_app, render_template, session, redirect
from glu import cache
from . import site
from . import helpers


@site.route('/')
def index():
  return render_template('index.jade',
    buster=str(int(time() * 1000)) if current_app.config.get('TESTING') else '',
    testing=current_app.config.get('TESTING', False),
    )
