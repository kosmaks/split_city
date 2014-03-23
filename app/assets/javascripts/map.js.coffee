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

  window.map = map = new ymaps.Map "map", {
    center: [55.156150, 61.409150]
    zoom: 10
  }

  fcm = new ShaderFCM avs: avs

  receiveVenues (venues) ->

    fcm.configure {
      clust: 16
      data: _.map(venues, (x) -> [x.lat * 1e6, x.lng * 1e6, 0, 0])
    }

    fcm.improve() for x in [0..50]

    weights = fcm.getWeights()
    clusters = {}
    numOfClusters = 0

    for i, venue of venues
      cluster = 0
      maxVal = 0
      for j, weight of weights[i]
        if weight > maxVal
          maxVal = weight
          cluster = j

      unless clusters[cluster]
        numOfClusters += 1
        clusters[cluster] = {
          data: [],
          size: 0,
          categories: {}
        }
      info = clusters[cluster]

      index = info.data.length
      info.data.push [venue.lat, venue.lng]

      info.categories[venue.category_id] ?= {
        count: 0,
        name: venue.category_name
      }
      info.categories[venue.category_id].count += 1

    for k, info of clusters
      info.category = _.max(_.values(info.categories), (x) -> x.count)

    for k, info of clusters
      info.polygon = Utils.grahamScan info.data

    for k, data of clusters
      line = new ymaps.Polygon [data.polygon, []], {
        hintContent: data.category.name
      }, {
        strokeWidth: 3,
        strokeColor: indexToColor(k)
        fillColor: indexToColor(k, '88')
      }
      map.geoObjects.add line

