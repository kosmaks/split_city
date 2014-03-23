#= require ./yandex_maps

class window.MapView extends Backbone.View
  el: '#map-layout'

  events: {
    ''
  }

  initialize: ->
    @map = new YandexMapsView {
      element: "map"
      ready: =>
        split_city.app.on 'sync', @update, @
        @update()
    }

  update: ->
    clust = split_city.app.getClusters()
    return unless clust?
    @map.clear()
    for k, info of clust
      @map.drawCluster k, info
