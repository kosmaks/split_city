$ -> ymaps.ready ->
  map = new ymaps.Map "map", {
    center: [55.156150, 61.409150]
    zoom: 13
  }

  $.ajax {
    url: 'zoning/debug'
    method: 'GET'
    dataType: 'JSON'

    success: (data) -> for venue in data
      console.log venue
      if venue.lat? and venue.lng?
        mark = new ymaps.Placemark [venue.lat, venue.lng]
        map.geoObjects.add mark

    failure: console.log
  }
