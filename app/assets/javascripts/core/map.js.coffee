#= require_tree .

# data

avs      = null
fcm      = null
map      = null
profiler = null
venues   = null
size     = 2
m        = 2
lastSize = null

clustersWorker = new VenueClusters

# steps

receiveVenues = (cb) ->
  $.get SPLIT_CITY.venue_source, {}, (data) ->
    venues = data
    cb?()

initProfiler = ->
  profiler = new Profiler
  profiler.begin()

initUI = (cb) ->
  # GL Context
  avs = new AVS $("#display")[0]
  unless avs.ready()
    $('#glErrorModal').modal({
      backdrop: 'static',
      keyboard: false
    })
    return false

  # UI Elements
  $(".clusters-count").slider({
    formater: (x) -> Math.pow(2, x) + " clusters"
  }).on('slide', (e) -> size = e.value)

  $(".m-parameter").slider().on('slide', (e) ->
    if m != e.value
      m = e.value
      lastSize = null
  )

  # Yandex maps
  ymaps.ready ->
    map = new ymaps.Map "map", {
      center: [55.156150, 61.409150]
      zoom: 11
    }
    cb?()

splitCity = ->
  timeout = 100

  if lastSize == size
    setTimeout splitCity, timeout

  else
    lastSize = size

    fcm ?= new ShaderFCM avs: avs
    fcm.configure {
      clust: Math.pow(2, size)
      data: _.map(venues, (x) -> [x.lat * 1e6, x.lng * 1e6, 0, 0])
      m: m
    }
    fcm.improve() for x in [0..50]

    clustersWorker.configure {
      venues: venues
      weights: fcm.getWeights()
    }

    clustersWorker.process (res) ->
      clusters = res.clusters

      map.geoObjects.each (x) ->
        map.geoObjects.remove x

      for k, data of clusters
        if SPLIT_CITY.show_points
          for venue in data.venues
            mark = new ymaps.Placemark [venue.lat, venue.lng], {
              hintContent: venue.name
            }
            map.geoObjects.add mark
          
        continue unless data.polygon?
        polygon = _.compact data.polygon
        continue if polygon.length <= 1

        line = new ymaps.Polygon [polygon, []], {
          hintContent: data.category.name
        }, {
          strokeWidth: 3,
          strokeColor: Utils.indexToColor(k)
          fillColor: Utils.indexToColor(k, '88')
        }
        map.geoObjects.add line

      setTimeout splitCity, timeout

# ui callbacks

handleSlide = (e) ->

# program entry

$ ->
  initUI ->
    receiveVenues ->
      splitCity()
