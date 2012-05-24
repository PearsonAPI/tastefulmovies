class Glu.RecipeView extends Glu.BaseView

  className: 'recipe'
  template: Glu.templates.recipe

  initialize: ->
    super()

    @tabView = new Glu.TabView(tabs: [
      {'id': 'recipe', label: 'Recipe'},
      {'id': 'movies', label: 'Movies'}
    ])

    @tabView.on 'select', @onTabSelect

  render: ->
    this.$el.html @template(recipe: @recipe, movies: @movies)
    this.$el.children('.bd').prepend @tabView.render().select('recipe').el if @recipe

    return this

  load: (id) ->
    @loading on
    $.get '/api/associate', {q: id}, (err, resp) =>
      @loading off
      @recipe = resp.query
      @movies = resp.results[0...5]
      @render()

    return this

  hide: ->
    @recipe = null
    @movies = null
    super()

  onTabSelect: (tab) =>
    steps = this.$('.recipe-steps')
    movies = this.$('.movies')

    if tab == 'recipe'
      steps.show()
      movies.hide()
    else
      steps.hide()
      movies.show()

