# data

avs      = null
fcm      = null
map      = null
profiler = null
venues   = null
size     = 2

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
  }).on('slide', handleSlide)

  # Yandex maps
  ymaps.ready ->
    map = new ymaps.Map "map", {
      center: [55.156150, 61.409150]
      zoom: 11
    }
    cb?()

lastSize = null
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

        #for venue in data.venues
          #mark = new ymaps.Placemark [venue.lat, venue.lng], {
            #hintContent: venue.name
          #}
          #map.geoObjects.add mark

        line = new ymaps.Polygon [data.polygon, []], {
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
  size = Number e.value

# program entry

$ ->
  initUI ->
    receiveVenues ->
      splitCity()
