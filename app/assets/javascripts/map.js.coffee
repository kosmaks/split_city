$ -> ymaps.ready ->
  return
  map = new ymaps.Map "map", {
    center: [55.156150, 61.409150]
    zoom: 13
  }

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


  $.ajax {
    url: 'zoning/debug'
    method: 'GET'
    dataType: 'JSON'

    success: (data) ->
      for venue in data.venues
        mark = new ymaps.Placemark [venue.lat, venue.lng], {}, {
          preset: coefToIcon(venue.weights)
        }
        map.geoObjects.add mark

      for i, center of data.centers
        console.log i, center
        mark = new ymaps.Placemark [center.lat, center.lng], {}, {
          preset: indexToIcon(i, 'Dot')
        }
        map.geoObjects.add mark

    failure: console.log
  }
