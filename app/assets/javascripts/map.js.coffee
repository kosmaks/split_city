$ -> ymaps.ready ->
  map = new ymaps.Map "map", {
    center: [55.156150, 61.409150]
    zoom: 16
  }

  $.ajax {
    url: 'zoning/debug'
    method: 'GET'
    dataType: 'JSON'

    success: (data) -> for venue in data
      mark = new ymaps.Placemark [venue.lat, venue.lng]
      map.geoObjects.add mark

    failure: console.log
  }
