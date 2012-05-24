# Globalish config for storing the actor and vendor.
config = {}


class Glu.GluApp extends Backbone.Router

  # Static class var so we can't initialize an app more than once
  initialized = false

  routes:
    'title/:id' : 'viewTitle'
  
  initialize: ->
    @view = null

  start: () ->
    return if initialized
    initialized = true

    # Initialize app view
    @view = new Glu.GluAppView()
    $('body').append @view.render().el

    # Start history monitoring
    Backbone.history.start()

  viewTitle: (id) ->
    return
