# Some models don't need to handle saving. Overriding the `save` method with
# `readonly` will make it throw an error when trying to save.
readonly = -> raise Error('Read only')


# Base model that all models inherit from.
# Has a parse method that strips away stuff we don't need from the platform
class Glu.BaseModel extends Backbone.Model

  parse: (resp) ->
    data = if resp.body then resp.body else resp
    # Extract elems if response is in the Drop format
    return data unless data.elems
    ret = {id: data.id}
    ret[key] = val.value for key, val of data.elems
    return ret


class Glu.BaseCollection extends Backbone.Collection

  initialize: ->
    super()
    @hasLoaded = false

  parse: (resp) -> if resp.body then resp.body else resp

  # Wraps the `read` action so we can set a `hasLoaded` flag. Some collections
  # don't need to be loaded more than once, and this lets us distinguish
  # between an empty collection that just hasn't been loaded and a collection
  # that has loaded but is empty.
  sync: (action, collection, options) ->
    if action = 'read'
      options ?= {}
      oldSuccess = options.success
      options.success = (args...) =>
        @hasLoaded = true
        oldSuccess and oldSuccess args...
    return Backbone.sync action, collection, options


# Generic contact card
class Glu.Card extends Glu.BaseModel

  url  : -> null
  save : readonly


# The logged in user's card
class Glu.MyCard extends Glu.Card

  url  : -> '/api/card'
  save : Glu.BaseModel::save

  defaults: ->
    email: config.email


# Vendor contact card
class Glu.VendorCard extends Glu.Card

  url  : -> "/api/vendor/#{@attributes.vendor_id}/card"
  save : Glu.BaseModel::save


# Calendar event
class Glu.Event extends Glu.BaseModel

  url  : -> null
  save : readonly

  setAttending: (attending) ->
    data = {}
    data[@id] = attending
    $.post '/api/calendar', data
    @set is_attending: attending


class Glu.Checkin extends Glu.BaseModel

  url  : -> null
  save : readonly


class Glu.CardCollection extends Glu.BaseCollection

  model: Glu.Card


# Logged in user's contact collection.
# Provides helper method that sync data with the server.
class Glu.MyContacts extends Glu.CardCollection

  url : -> '/api/contacts'

  comparator: (contact) ->
    first = contact.get('first_name') or ''
    last  = contact.get('last_name') or ''
    return $.trim(first + ' ' + last).toLowerCase()

  addContact: (models, options) ->
    models = if _.isArray models then models.slice() else [models]
    data = {}; data[model.id] = true for model in models
    $.post '/api/contacts', data
    return @add models, options

  removeContact: (models, options) ->
    models = if _.isArray models then models.slice() else [models]
    data = {}; data[model.id] = false for model in models
    $.post '/api/contacts', data
    return @remove models, options


# Calendar event collection
# Provides helper methods that will group events by starting time.
class Glu.EventCollection extends Glu.BaseCollection
  # Static helper method for grouping a list of events
  group = (events) ->
    grouped = _.groupBy events, (ev) -> ev.start_time
    times   = _.keys(grouped).sort()
    groups  = ([parseInt(t), grouped[t]] for t in times)

  model: Glu.Event

  # Returns an array of tuples: [date, [events]]
  grouped: ->
    events = @toJSON()
    group events

  # Returns an array of tuples like `grouped`, but only those that the
  # current user is going to attend.
  groupedAttending: ->
    events = @toJSON()
    group _.filter(events, (ev) -> ev.is_attending)


class Glu.CheckinCollection extends Glu.BaseCollection

  model: Glu.Checkin
  comparator: (checkin) -> -checkin.get 'timestamp'
