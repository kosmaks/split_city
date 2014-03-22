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

# program entry
$ -> ymaps.ready ->

  fcm = new ShaderFCM $("#display")[0]

  receiveVenues (venues) ->

    fcm.configure {
      data: _.map(venues, (x) -> [x.lat * 1e6, x.lng * 1e6, 0, 0])
    }

    fcm.improve()

  #map = new ymaps.Map "map", {
    #center: [55.156150, 61.409150]
    #zoom: 13
  #}
