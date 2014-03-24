class window.Router extends Backbone.Router

  prevView = null

  routes: {
    '': 'map'
    'map': 'map'
    'clust-stats': 'clustStats'
    'venues-stats': 'venuesStats'
  }

  initialize: ->
    @navbarView = new NavbarView

  map: ->
    @mapView ?= new window.MapView
    @switchView @mapView

  clustStats: ->
    @clustStatsView ?= new window.ClustStatsView
    @switchView @clustStatsView

  venuesStats: ->
    @venuesStatsView ?= new window.VenuesStatsView
    @switchView @venuesStatsView

  switchView: (view) ->
    if prevView?
      prevView.$el.hide()
      prevView.navigatedFrom?()

    prevView = view
    view.$el.show()
    view.navigatedTo?()
