class Glu.GluAppView extends Glu.BaseView

  id: 'app'
  template: Glu.templates.app

  initialize: ->
    super()

    # Initialize subviews
    @searchView = new Glu.SearchView()
    @recipeView = (new Glu.RecipeView).hide()

  render: ->
    this.$el.html @template()
    this.$el.children('.bd')
      .append(@searchView.render().el)
      .append(@recipeView.el)

    return this
