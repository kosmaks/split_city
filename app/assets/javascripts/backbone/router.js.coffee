class window.Router extends Backbone.Router

  prevView = null

  routes: {
    '': 'map'
    'map': 'map'
    'clust-stats': 'clustStats'
  }

  map: ->
    @mapView ?= new window.MapView
    @switchView @mapView

  clustStats: ->
    @clustStatsView ?= new window.ClustStatsView
    @switchView @clustStatsView

  switchView: (view) ->
    if prevView?
      prevView.$el.hide()
      prevView.navigatedFrom?()

    prevView = view
    view.$el.show()
    view.navigatedTo?()
