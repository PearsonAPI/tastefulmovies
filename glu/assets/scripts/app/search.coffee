class Glu.SearchView extends Glu.BaseView
  
  className: "search"
  template: Glu.templates.search

  events: ->
    events =
      'keypress .search-input': 'onKeyPress'
      'input .search-input': 'onInput'
      'click .add': 'onSelectIngredient'
      'click .remove': 'onRemoveIngredient'
      'click .recipe-result': 'onSelectRecipe'
    return events

  initialize: ->
    super()
    @ingredients = []

  renderIngredients: (ingredients) ->
    html = (Glu.templates['ingredient-result'] name:i for i in ingredients).join ''
    html = "<ul>#{html}</ul>"
    this.$('.ingredient-results').html html

  clearResults: ->
    this.$('.ingredient-results').html('') 
    this.$('.search-input').get(0).select()

  getRecipes: ->
    return this.$('.results').remove() unless @ingredients.length
    $.get '/api/search', {q: @ingredients.join ''}, (err, resp) =>
      this.$el.children('.bd').html Glu.templates.results(results: resp.results)

  onKeyPress: _.throttle (e) ->
    query = $(e.currentTarget).val()
    if query && e.keyCode == 13
      @renderIngredients [query]

  onInput: _.throttle (e) ->
    query = $(e.currentTarget).val()
    return @clearResults() unless query
    $.get '/api/autocomplete', {q: query}, (err, resp) =>
      @renderIngredients (r for r in resp.results when r not in @ingredients)[0...5]
    , 400

  onSelectIngredient: (e) ->
    name = $(e.currentTarget).data 'name'
    this.$('.ingredient-choices ul').prepend Glu.templates['ingredient-choice']({name})
    @ingredients.push name
    @clearResults()
    @getRecipes()

  onRemoveIngredient: (e) ->
    name = $(e.currentTarget).data 'name'
    $(e.currentTarget).closest('li').remove()
    @ingredients = _.without @ingredients, name
    @getRecipes()

  onSelectRecipe: (e) ->
    id = $(e.currentTarget).data 'id'
    window.location.hash = "recipe/" + id
