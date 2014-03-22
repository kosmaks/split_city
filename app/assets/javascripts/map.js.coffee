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

  map = new ymaps.Map "map", {
    center: [55.156150, 61.409150]
    zoom: 10
  }

  fcm = new ShaderFCM avs: avs

  receiveVenues (venues) ->

    fcm.configure {
      clust: 64
      data: _.map(venues, (x) -> [x.lat * 1e6, x.lng * 1e6, 0, 0])
    }

    for i in [0...1000]
      fcm.improve()

    weights = fcm.getWeights()
    clusters = {}

    for i, venue of venues

      cluster = 0
      maxVal = 0
      for j, weight of weights[i]
        if weight > maxVal
          maxVal = weight
          cluster = j

      clusters[cluster] ?= {
        onEdge: null,
        data: [],
        size: 0
      }
      info = clusters[cluster]

      index = info.data.length
      if not info.onEdge? or (info.data[info.onEdge][0] * 1e6 > venue.lat * 1e6)
        info.onEdge = index
      info.data.push [venue.lat, venue.lng]

    console.log clusters

    for k, info of clusters

      edge = info.data[info.onEdge]
      info.data.splice info.onEdge
      info.data.sort Utils.crossComparator(edge)

      data = [edge, info.data[0]]
      i = 1

      while i < info.data.length #and confirm('next')
        j = data.length - 1
        point = info.data[i]

        comp = Utils.crossComparator(data[j])(data[j-1], point)
        #console.log comp

        if comp > 0
          data.push(point)
          i += 1
        else
          data.pop()

      console.log data

      line = new ymaps.Polygon [data, []], {}, {
        strokeWidth: 3,
        strokeColor: indexToColor(k)
        fillColor: indexToColor(k, '88')
      }
      map.geoObjects.add line
