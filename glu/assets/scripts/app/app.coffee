class Glu.GluAppView extends Glu.BaseView

  id: 'app'
  template: Glu.templates.app

  initialize: ->
    # Initialize subviews
    @loginView     = (new Glu.LoginView).hide()
    @dashboardView = (new Glu.DashboardView).hide()
    @eventsView    = (new Glu.EventsView).hide()
    @contactsView  = (new Glu.ContactsView).hide()
    @checkinsView  = (new Glu.CheckinsView).hide()
    @vendorView    = (new Glu.VendorView).hide()

    Glu.me.on 'change:vendor_key', @onChangeVendor

  render: ->
    this.$el.html @template(config)
    this.$el.children('.bd')
      .append(@loginView.el)
      .append(@dashboardView.el)
      .append(@eventsView.el)
      .append(@contactsView.el)
      .append(@checkinsView.el)
      .append(@vendorView.el)

    return this

  select: (index) ->
    this.$('.nav li')
      .removeClass('selected')
      .eq(index)
        .addClass('selected')

  onChangeVendor: =>
    vendor_id  = Glu.me.get 'vendor_id'
    vendor_key = Glu.me.get 'vendor_key'

    if vendor_id and vendor_key
      config.vendor = vendor_id
      this.$el.addClass 'vendor-app'
    else
      config.vendor = null
      this.$el.removeClass 'vendor-app'
