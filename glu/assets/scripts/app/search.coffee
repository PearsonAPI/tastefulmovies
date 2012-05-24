class Glu.SearchView extends Glu.BaseView
  
  className: "search"
  template: Glu.templates.search

  events: ->
    events =
      'input .search-input': 'onInput'
      'click .add': 'onSelectIngredient'
      'click .remove': 'onRemoveIngredient'
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
    console.log @ingredients.join(',')

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
