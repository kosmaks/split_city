class window.YandexMapsView extends Backbone.View

  map = null

  initialize: (options) ->
    @element = options.element ? "map"
    @center = options.center ? [55.156150, 61.409150]
    @zoom = options.zoom ? 11

  render: (cb) -> ymaps.ready =>
    map = new ymaps.Map @element, {
      center: @center
      zoom: @zoom
    }
    cb?()

  clear: ->
    map.geoObjects.each (x) ->
      map.geoObjects.remove x

  drawCluster: (k, info) ->
    return unless info.polygon?
    polygon = _.compact info.polygon
    return if polygon.length <= 1

    line = new ymaps.Polygon [polygon, []], {
      hintContent: info.category.name
    }, {
      strokeWidth: 3,
      strokeColor: Utils.indexToColor(k)
      fillColor: Utils.indexToColor(k, '88')
    }
    map.geoObjects.add line
