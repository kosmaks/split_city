class window.YandexMapsView extends Backbone.View

  map = null
  knownCats = []

  initialize: (options) ->
    @element = options.element ? "map"
    @center = options.center ? [55.156150, 61.409150]
    @zoom = options.zoom ? 11

  render: (cb) -> ymaps.ready =>
    map = new ymaps.Map @element, {
      center: @center
      zoom: @zoom
    }
    map.controls.add 'mapTools'
    map.controls.add 'typeSelector'
    map.controls.add 'zoomControl'
    cb?()

  clear: ->
    map.geoObjects.each (x) ->
      map.geoObjects.remove x

  drawSimpleCluster: (k, info) ->
    index = @categoryIndex info.category.id

    objects = _.map info.venues, (venue) =>
      index = @categoryIndex venue.categories[0].id
      new ymaps.Placemark [venue.lat, venue.lng], {
        hintContent: venue.name
      }, {
        preset: Utils.indexToTwirl(index)
      }
    clusterer = new ymaps.Clusterer {
      clusterDisableClickZoom: true
      preset: Utils.indexToClusterTwirl(index)
    }
    clusterer.add objects
    map.geoObjects.add clusterer


  drawCluster: (k, info) ->
    return unless info.polygon?
    polygon = _.compact info.polygon
    return if polygon.length <= 1

    index = @categoryIndex info.category.id

    fig = new ymaps.Polygon [polygon, []], {
      hintContent: info.category.name
    }, {
      strokeWidth: 3,
      strokeColor: Utils.indexToColor(index)
      fillColor: Utils.indexToColor(index, '88')
    }
    map.geoObjects.add fig

  drawLines: (k, info) ->
    return unless info.venues?

    line = new ymaps.Polyline _.map(info.venues, (x) -> [x.lat, x.lng]), {
      hintContent: info.category.name
    }, {
      strokeWidth: 3,
      strokeColor: Utils.indexToColor(k)
    }
    map.geoObjects.add line

  drawVenue: (k, cluster, venue) ->

    category = venue.categories[0]
    index = @categoryIndex category.id

    line = new ymaps.Polyline [[venue.lat, venue.lng], [venue.lat + 0.0003, venue.lng]], {
      hintContent: category.name
    }, {
      strokeWidth: 5,
      strokeColor: Utils.indexToColor(index)
    }
    map.geoObjects.add line

  categoryIndex: (catId) ->
     index = _.indexOf knownCats, catId
     if index < 0
       knownCats.push catId
       index = knownCats.length - 1
     index
