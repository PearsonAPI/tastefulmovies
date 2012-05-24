# Globalish config for storing the actor and vendor.
config = {}


class Glu.GluApp extends Backbone.Router

  # Static class var so we can't initialize an app more than once
  initialized = false

  routes:
    'login'     : 'login'
    'dashboard' : 'dashboard'
    'events'    : 'events'
    'contacts'  : 'contacts'
    'checkins'  : 'checkins'
    'vendor'    : 'vendor'
  
  initialize: ->
    @view = null
    @activeView = null

  start: (actor, email, vendor) ->
    return if initialized
    initialized = true

    # Set config
    config = {actor, email, vendor}

    # Setup global models/collections
    Glu.me       = new Glu.MyCard
    Glu.events   = new Glu.EventCollection
    Glu.checkins = new Glu.CheckinCollection
    Glu.contacts = new Glu.MyContacts

    # These have custom urls
    Glu.events.url   = -> '/api/calendar'
    Glu.checkins.url = -> '/api/checkins'

    # Initialize app view
    @view = new Glu.GluAppView()
    $('body').append @view.render().el
    @enableVendor() if vendor

    # Show login page if not logged in
    if not actor then window.location.hash = 'login'

    # Fetch my profile and show the dashboard
    else window.location.hash = 'dashboard' unless window.location.hash

    # Start history monitoring
    Backbone.history.start()

  enableVendor: (vendor) ->
    config.vendor = vendor if vendor
    @view.$el.addClass 'vendor-app'

  login: ->
    @activeView?.clear().hide()
    @activeView = @view.loginView.show()

  # Static helper for switching tabs
  changeTab = (tab, view) ->
    return ->
      @view.select tab
      @activeView?.clear().hide()
      @activeView = @view[view + 'View'].show().load()

  dashboard : changeTab 0, 'dashboard'
  events    : changeTab 1, 'events'
  contacts  : changeTab 2, 'contacts'
  checkins  : changeTab 3, 'checkins'
  vendor    : changeTab 4, 'vendor'
