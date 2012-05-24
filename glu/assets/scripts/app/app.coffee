class Glu.GluAppView extends Glu.BaseView

  id: 'app'
  template: Glu.templates.app

  initialize: ->
    super()

    # Initialize subviews
    @searchView = new Glu.SearchView()

  render: ->
    this.$el.html @template()
    this.$el.children('.bd')
      .append(@searchView.render().el)

    return this

