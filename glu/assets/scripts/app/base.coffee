# Canned responses
Glu.can =
  error: 'An error occurred. Please try again later.'


# Base view that all views inherit from.
# Will lazily render based on calling show()
class Glu.BaseView extends Backbone.View

  initialize: ->
    @isRendered = false
    @isLoading = false

  render: ->
    @isRendered = true
    if $.isFunction @template
      this.$el.html(@template())
    return this

  show: (render = false) -> 
    this.render() if render or not @isRendered
    this.$el.show()
    return this

  hide: -> 
    this.$el.hide()
    return this

  clear: ->
    @isRendered = false
    this.$el.html ''
    return this

  # Turn the loading indicator `on` or `off`.
  # By default it will prepend it to the view's el, but that can be overriden
  # by supplying a target element
  loading: (visible, target) ->
    @isLoading = visible
    target = $(target) if target
    el = (target or this.$el).find('.loading')
    if visible and !el.length then (target or this.$el).prepend Glu.templates.loading()
    if el.length and !visible then el.remove()
    return this


# Simple tab UI component
class Glu.TabView extends Backbone.View

  tagName   : 'ul'
  className : 'tabs'

  events: ->
    tap = if $.os.tap then 'tap' else 'click'
    events = {}
    events[tap + ' li'] = 'onSelectTab'
    return events

  initialize: ->
    @tabs = @options.tabs or []

  render: ->
    html = ("<li data-id=\"#{id}\">#{label}</li>" for {label, id} in @tabs)
    this.$el.html html.join('')

    if @currentTab
      this.$el.find('li').filter("*[data-id=#{@currentTab}]").addClass 'selected'

    # Good to redelegate events in case the parent view was rerendered,
    # otherwise events might get lost
    @delegateEvents()

    return this

  select: (tabId) ->
    if typeof tabId == 'string'
      # Weird selector wrangling because of zepto/querySelectorAll errors
      tab = this.$el.find('li').filter("*[data-id=#{tabId}]")
    else 
      tab = tabId
      tabId = tab.attr 'data-id'

    return this if tabId == @currentTab

    tab.addClass('selected').siblings().removeClass('selected')
    @currentTab = if tab.length then tabId else null
    @trigger 'select', tabId
    return this

  onSelectTab: (e) ->
    @select $(e.currentTarget)
    
