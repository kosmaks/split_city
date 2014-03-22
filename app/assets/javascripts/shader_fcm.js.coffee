$ -> ymaps.ready ->
  map = new ymaps.Map "map", {
    center: [55.156150, 61.409150]
    zoom: 10
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

  $.get 'zoning/index', {}, (venues) ->

    length = venues.length
    x = 1
    while x*x < length then x *= 2
    array = _.map(venues, (x) -> [x.lat * 1e6, x.lng * 1e6, 0, 0])
    while array.length < (x*x) then array.push [0, 0, 1.0, 0]

    size = [x, x]
    data = _.flatten(array)
    #size = [4, 1]
    #data = [0.1, 0.0, 0.0, 0.0,
            #0.1, 0.0, 0.0, 0.0,
            #0.1, 0.9, 0.0, 0.0,
            #0.1, 0.9, 0.0, 0.0]


    avs = new AVS document.getElementById('display')

    sizeM = size[0] * size[1]
    sizex = "#{size[0]}.0"
    sizey = "#{size[1]}.0"

    m     = 2.0
    mpow  = 2.0 / (m - 1)
    clust = 8

    texVertex = """
    attribute vec2 vertex;
    varying vec2 index;

    void main() {
      index.x = (vertex.x > 0.) ? 1. : 0.;
      index.y = (vertex.y > 0.) ? 1. : 0.;
      gl_Position = vec4(vertex, 0., 1.);
    }
    """

    mainProg = avs.createProgram {
      vertex: texVertex
      fragment: """
      precision mediump float;
      uniform sampler2D sampler;
      varying vec2 index;

      void main() {
        gl_FragColor = texture2D(sampler, index);
        gl_FragColor.w = 1.;
      }
      """
    }

    weightsProg = avs.createProgram {
      vertex: texVertex
      fragment: """
      precision mediump float;
      uniform sampler2D clust;
      uniform sampler2D data;
      varying vec2 index;

      void main() {
        float weight = texture2D(clust, index).x;
        vec3 data = texture2D(data, index).xyz;
        vec2 point = data.xy;

        float denum = pow(weight, #{m}.);

        gl_FragColor = vec4(point * denum, denum, data.z);
      }
      """
    }

    sumProg = avs.createProgram {
      vertex: texVertex
      fragment: """
      precision mediump float;
      uniform sampler2D weights;
      uniform sampler2D backbuffer;
      varying vec2 index;

      void main() {
        float clust = floor(index.x * #{clust}.);
        float delta = #{(1.0 / (size[0] * clust))} * clust;

        vec2 vecs = vec2(0., 0.);
        float w = 0.;

        float c = 0.;
        for (float i = 0.; i < #{sizex}; i += 1.)
        for (float j = 0.; j < #{sizey}; j += 1.) {
          vec2 cellPos = vec2(i / #{sizex}, j / #{sizey});
          cellPos.x += delta;
          vec4 point = texture2D(weights, cellPos);
          if (point.w > 0.5) continue;

          vecs += point.xy;
          w += point.z;
          c += 1.;
        }

        if (w > 0.00001)
          gl_FragColor = vec4(vecs / w, 0., 1.);
        else
          gl_FragColor = texture2D(backbuffer, index);
      }
      """
    }

    normalizeProg = avs.createProgram {
      vertex: texVertex
      fragment: """
      precision mediump float;
      uniform sampler2D backbuffer;
      uniform sampler2D centers;
      uniform sampler2D data;
      varying vec2 index;

      void main() {
        vec4 data = texture2D(data, index);
        if (data.z > 0.5) return;

        float clusterId = floor(mod(index.x * #{size[0] * clust}., #{clust}.));

        vec2 point = data.xy;
        vec2 center = texture2D(centers, vec2(clusterId / #{clust}., 0.5)).xy;

        float disti = distance(point, center);
        float sum = 0.;

        for (float k = 0.; k < #{clust}.; k += 1.) {
          vec2 pos = vec2(k / #{clust}., 0.5);
          vec2 relCenter = texture2D(centers, pos).xy;
          float distj = distance(point, relCenter);
          sum += pow(disti / distj, 2.);
        }

        if (sum > 0.00001)
          gl_FragColor = vec4(1. / sum, 0., 0., 1.);
        else
          gl_FragColor = texture2D(backbuffer, index);
      }
      """
    }

    randomData = []
    for x in [0...size[0]]
      for y in [0...size[1]]
        sum = 1.0
        for k in [0...clust-1]
          perc = Math.random() * sum
          if perc > sum then perc = sum
          randomData.push perc
          randomData.push 0.0
          randomData.push 0.0
          randomData.push 0.0
          sum -= perc
        randomData.push sum
        randomData.push 0.0
        randomData.push 0.0
        randomData.push 0.0

    initBuf    = avs.createFramebuffer size: size, data: new Float32Array(data)
    clust1Buf  = avs.createFramebuffer size: [size[0] * clust, size[1]], data: new Float32Array(randomData)
    clust2Buf  = avs.createFramebuffer size: [size[0] * clust, size[1]]
    weights1Buf = avs.createFramebuffer size: [size[0] * clust, size[1]]
    weights2Buf = avs.createFramebuffer size: [size[0] * clust, size[1]]
    centers1Buf = avs.createFramebuffer size: [clust, 1]
    centers2Buf = avs.createFramebuffer size: [clust, 1]

    trig = false
    clustIn    = null
    weightsIn  = null
    centersIn  = null
    clustOut   = null
    weightsOut = null
    centersOut = null

    objects = []

    #setInterval(->
    for i in [0..20]
      clustIn    = if trig then clust2Buf   else clust1Buf
      clustOut   = if trig then clust1Buf   else clust2Buf
      centersIn  = if trig then centers2Buf else centers1Buf
      centersOut = if trig then centers1Buf else centers2Buf
      weightsIn  = if trig then weights2Buf else weights1Buf
      weightsOut = if trig then weights1Buf else weights2Buf

      inBuf = if trig then clust2Buf else clust1Buf
      outBuf = if trig then clust1Buf else clust2Buf
      avs.pass weightsProg,   weightsOut, backbuffer: weightsIn.texture,  clust: clustIn.texture,      data: initBuf.texture
      avs.pass sumProg,       centersOut, backbuffer: centersIn.texture,  weights: weightsOut.texture
      avs.pass normalizeProg, clustOut,   centers:    centersOut.texture, data: initBuf.texture
      trig = not trig

      avs.useProgram mainProg, (prog) ->
        avs.clear()
        avs.useTexture clustOut.texture
        prog.drawDisplay()

      weights = avs.readPixels(clustOut)
      count = 0
      out = ""

      #for i in [0...weights.length]
        #out += (weights[i] / 255).toFixed(4) + "\t"
        #if count == 3
          #console.log out
          #out = ""
          #count = 0
        #else
          #count += 1
      #console.log '- - -'

    for i in [0...venues.length]
      max = 0
      cluster = 0

      for k in [0...clust]
        val = weights[4 * (i * clust + k)]
        if val > max
          cluster = k
          max = val

      mark = new ymaps.Placemark [venues[i].lat, venues[i].lng], {}, {
        preset: indexToIcon(cluster)
      }
      objects.push mark
      map.geoObjects.add mark
      #, 1000)
