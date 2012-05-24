class Glu.RecipeView extends Glu.BaseView

  className: 'recipe'
  template: Glu.templates.recipe

  initialize: ->
    super()

    @tabView = new Glu.TabView(tabs: [
      {'id': 'recipe', label: 'Recipe'},
      {'id': 'movies', label: 'Movies'}
    ])

  render: ->
    this.$el.html @template(recipe: @recipe)
    this.$el.children('.bd').prepend @tabView.render().select('recipe').el

    return this
