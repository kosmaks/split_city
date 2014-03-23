receiveVenues = (cb) -> $.get 'zoning/index', {}, cb

coefToIcon = (coef, type='') ->
  index = _.sortBy(_.pairs(coef), (x) -> -x[1])[0][0]
  indexToIcon index, type

indexToIcon = (index, type='') ->
  switch "#{index}"
    when '0' then "twirl#blue#{type}Icon"
    when '1' then "twirl#red#{type}Icon"
    when '2' then "twirl#green#{type}Icon"
    when '3' then "twirl#orange#{type}Icon"
    when '4' then "twirl#pink#{type}Icon"
    when '5' then "twirl#gray#{type}Icon"
    when '6' then "twirl#night#{type}Icon"
    when '7' then "twirl#black#{type}Icon"

indexToColor = (index, extra='') ->
  switch "#{index}"
    when '0'  then "#000000" + extra
    when '1'  then "#ff0000" + extra
    when '2'  then "#00ff00" + extra
    when '3'  then "#ffff00" + extra
    when '4'  then "#0000ff" + extra
    when '5'  then "#ff00ff" + extra
    when '6'  then "#00ffff" + extra
    when '8'  then "#ffffff" + extra
    when '9'  then "#0000aa" + extra
    when '10' then "#ff00aa" + extra
    when '11' then "#00ffaa" + extra
    when '12' then "#ffffaa" + extra
    when '13' then "#aa00ff" + extra
    when '14' then "#ffaaff" + extra
    when '15' then "#aaffff" + extra
    when '16' then "#ffffaa" + extra

# program entry
$ -> ymaps.ready ->

  avs = new AVS $("#display")[0]
  profiler = new Profiler
  profiler.begin()

  window.map = map = new ymaps.Map "map", {
    center: [55.156150, 61.409150]
    zoom: 10
  }

  profiler.checkpoint "Created map"

  fcm = new ShaderFCM avs: avs

  receiveVenues (venues) ->

    profiler.checkpoint "Received venues"

    fcm.configure {
      clust: 4
      data: _.map(venues, (x) -> [x.lat * 1e6, x.lng * 1e6, 0, 0])
    }

    profiler.checkpoint "Configured fcm"

    fcm.improve() for x in [0..50]

    profiler.checkpoint "Improved results"

    weights = fcm.getWeights()

    clusters = new VenueClusters
    clusters.configure {
      venues: venues
      weights: weights
    }

    clusters.process (res) ->
      for k, data of res.clusters
        line = new ymaps.Polygon [data.polygon, []], {
          hintContent: data.category.name
        }, {
          strokeWidth: 3,
          strokeColor: indexToColor(k)
          fillColor: indexToColor(k, '88')
        }
        map.geoObjects.add line

      profiler.end "Drawn clusters"
