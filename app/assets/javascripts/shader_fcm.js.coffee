$ ->
  $.get 'zoning/index', {}, (data) ->
    length = data.length
    x = 1
    while x*x < length then x *= 2
    array = _.map(data, (x) -> [x.lat, x.lng, 0, 0])
    while array.length < (x*x) then array.push [0, 0, 0, 0]

    #startAvs [x, x], _.flatten(array)
    return
    startAvs [2, 2], [0.1, 0.0, 0.0, 0.0,
                      0.1, 0.0, 0.0, 0.0,
                      0.2, 0.0, 0.0, 0.0,
                      0.3, 0.0, 0.0, 0.0]


startAvs = (size = [16, 16], data = []) ->
  avs = new AVS document.getElementById('display')

  sizeM = size[0] * size[1]
  sizex = "#{size[0]}.0"
  sizey = "#{size[1]}.0"

  m     = 2.0
  mpow  = 2.0 / (m - 1)
  clust = 2

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

  pointsProg = avs.createProgram {
    vertex: """
    attribute vec2 vertex;

    void main() {
      gl_PointSize = 5.;
      gl_Position = vec4((vertex / 127.5) - 1., 0., 1.);
    }
    """
    fragment: """
    void main() {
      gl_FragColor = vec4(0.1, 0.4, 1., 1.);
    }
    """
  }

  fillProg = avs.createProgram {
    vertex: texVertex
    fragment: """
    precision mediump float;
    uniform sampler2D data;
    varying vec2 index;

    void main() {
      vec4 src = texture2D(data, index);
      gl_FragColor = vec4(
        src.x,
        src.y,
        0.,
        1.
      );
    }
    """
  }

  randProg = avs.createProgram {
    vertex: texVertex
    fragment: """
    precision mediump float;
    varying vec2 index;

    void main() {
      gl_FragColor = vec4(
        index.x,
        index.y,
        0.,
        1.
      );
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
      float coef = texture2D(clust, index).x;
      vec2 dataVec = texture2D(data, index).xy;
      float powM = pow(coef, #{m}.);

      gl_FragColor = vec4(dataVec * powM, powM, 1.);
    }
    """
  }

  sumProg = avs.createProgram {
    vertex: texVertex
    fragment: """
    precision mediump float;
    uniform sampler2D weights;
    varying vec2 index;

    void main() {
      float k = floor(index.x * #{clust}.);
      vec2 vecs = vec2(0., 0.);
      float w = 0.;

      for (float i = 0.; i < #{sizex}; i += 1.)
      for (float j = 0.; j < #{sizey}; j += 1.) {
        vec2 pos = floor(vec2(k * i / #{sizex}, j / #{sizey}));
        vec3 data = texture2D(weights, pos).xyz;
        vecs += data.xy;
        w += data.z;
      }

      gl_FragColor = vec4(vecs / w, 0., 1.);
    }
    """
  }

  normalizeProg = avs.createProgram {
    vertex: texVertex
    fragment: """
    precision mediump float;
    uniform sampler2D centers;
    uniform sampler2D data;
    varying vec2 index;

    void main() {
      float step = 1. / #{clust * size[0]}.;

      float dataX = index.x * #{clust * size[0]}.;
      dataX = floor(dataX / #{clust}.);
      float centerX = dataX * #{clust}. * step;
      dataX = dataX / #{sizex};

      vec2 center = texture2D(centers, index).xy;
      vec2 point  = texture2D(data, vec2(dataX, index.y)).xy;

      float sum = 0.;
      for (float k = 0.; k < #{clust}.; k += 1.) {
        float offset = centerX + step * k;
        vec2 centerK = texture2D(centers, vec2(offset, index.y)).xy;

        sum += point.x;
        //sum += pow(length(center - point) / length(centerK - point), #{mpow}.);
      }

      gl_FragColor = vec4(sum, 0., 0., 1.);
    }
    """
  }

  console.log data
  dataBuf    = avs.createFramebuffer size: size, data: new Float32Array(data)
  initBuf    = avs.createFramebuffer size: size
  clust1Buf  = avs.createFramebuffer size: [size[0] * clust, size[1]]
  clust2Buf  = avs.createFramebuffer size: [size[0] * clust, size[1]]
  weightsBuf = avs.createFramebuffer size: [size[0] * clust, size[1]]
  centersBuf = avs.createFramebuffer size: [clust, 1]

  avs.pass fillProg, initBuf, data: dataBuf.texture
  avs.pass randProg, clust1Buf

  trig = false

  for x in [1..1]
    inBuf = if trig then clust2Buf else clust1Buf
    outBuf = if trig then clust1Buf else clust2Buf
    avs.pass weightsProg, weightsBuf, clust: inBuf.texture, data: initBuf.texture
    outBuf = clust1Buf
    #avs.pass sumProg, centersBuf, weights: weightsBuf.texture
    #avs.pass normalizeProg, outBuf, centers: centersBuf.texture, data: dataBuf.texture
    trig = not trig

  avs.useProgram mainProg, (prog) ->
    console.log _.map(avs.readPixels(outBuf), (x) -> x / 255.0)
    avs.clear()
    avs.useTexture outBuf.texture
    prog.drawDisplay()
