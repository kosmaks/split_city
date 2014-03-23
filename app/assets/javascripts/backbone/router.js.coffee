class window.Router extends Backbone.Router
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
    $('.layout').hide()
    view.$el.show()
