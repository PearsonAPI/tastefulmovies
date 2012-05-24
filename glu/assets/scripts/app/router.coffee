# Globalish config for storing the actor and vendor.
config = {}


class Glu.GluApp extends Backbone.Router

  # Static class var so we can't initialize an app more than once
  initialized = false

  routes:
    '' : 'search'
    'recipe/:id' : 'viewRecipe'
  
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

  search: ->
    @view.searchView.show()
    @view.recipeView.hide()

  viewRecipe: (id) ->
    @view.recipeView.show().load(id)
    @view.searchView.hide()
