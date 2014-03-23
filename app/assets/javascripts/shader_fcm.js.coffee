class window.ShaderFCM

  fixedSize = 10
  texVertex = """
  attribute vec2 vertex;
  varying vec2 index;

  void main() {
    index.x = (vertex.x > 0.) ? 1. : 0.;
    index.y = (vertex.y > 0.) ? 1. : 0.;
    gl_Position = vec4(vertex, 0., 1.);
  }
  """

  # initializer data
  avs  = null
  data = null
  size = null
  conf = {}

  # programs
  mainProg      = null
  weightsProg   = null
  sumProg       = null
  normalizeProg = null

  # buffers
  initBuf     = null
  doubleBuffers = {
    clust1:   null
    clust2:   null
    weights1: null
    weights2: null
    centers1: null
    centers2: null
  }

  # sizes
  clustNodeSize = -> size[0] * conf.clust
  clustNodeBufSize = -> [clustNodeSize(), size[1]]
  clustBufSize = -> [conf.clust, 1]

  # shader helpers
  fix = (x) -> x.toFixed fixedSize
  clustNode = -> fix clustNodeSize()
  sizex     = -> fix size[0]
  sizey     = -> fix size[1]
  clust     = -> fix conf.clust
  m         = -> fix conf.m
  mpow      = -> fix (2.0 / (conf.m - 1.0))

  # runtime
  trig = false

  constructor: (options = {}) ->
    avs = options.avs ? new AVS options.elem

  configure: (options = {}) ->
    conf.m     = options.m ? 2.0
    conf.clust = options.clust ? 4
    array      = options.data ? []
    length     = array.length

    # align to power of 2
    size = Utils.alignToTexture length
    Utils.fillRestWith array, (size[0] * size[1]), [0, 0, 1, 0]
    data = _.flatten(array)

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

        float denum = pow(weight, #{m()});

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
        float clust = floor(index.x * #{clust()});
        float delta = #{fix(1.0 / clustNodeSize())} * clust;

        vec2 vecs = vec2(0., 0.);
        float w = 0.;

        float c = 0.;
        for (float i = 0.; i < #{sizex()}; i += 1.)
        for (float j = 0.; j < #{sizey()}; j += 1.) {
          vec2 cellPos = vec2(i / #{sizex()}, j / #{sizey()});
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

        float clusterId = floor(mod(index.x * #{clustNode()}, #{clust()}));

        vec2 point = data.xy;
        vec2 center = texture2D(centers, vec2(clusterId / #{clust()}, 0.5)).xy;

        float disti = distance(point, center);
        float sum = 0.;

        for (float k = 0.; k < #{clust()}; k += 1.) {
          vec2 pos = vec2(k / #{clust()}, 0.5);
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

    initBuf = avs.createFramebuffer {
      size: size,
      data: new Float32Array(data)
    }

    doubleBuffers['clust1'] = avs.createFramebuffer {
      size: clustNodeBufSize(),
      data: new Float32Array(@generateRandomWeights())
    }

    doubleBuffers['clust2']   = avs.createFramebuffer size: clustNodeBufSize()
    doubleBuffers['weights1'] = avs.createFramebuffer size: clustNodeBufSize()
    doubleBuffers['weights2'] = avs.createFramebuffer size: clustNodeBufSize()
    doubleBuffers['centers1'] = avs.createFramebuffer size: clustBufSize()
    doubleBuffers['centers2'] = avs.createFramebuffer size: clustBufSize()

    trig = false

  improve: ->
    avs.pass weightsProg, @getOutBuf('weights'), {
      backbuffer: @getInBuf('weights').texture,
      clust: @getInBuf('clust').texture,
      data: initBuf.texture
    }
    avs.pass sumProg, @getOutBuf('centers'), {
      backbuffer: @getInBuf('centers').texture,
      weights: @getOutBuf('weights').texture
    }
    avs.pass normalizeProg, @getOutBuf('clust'), {
      centers: @getOutBuf('centers').texture,
      data: initBuf.texture
    }
    trig = not trig

  getOutBuf: (category) ->
    num = if trig then 1 else 2
    doubleBuffers["#{category}#{num}"]

  getInBuf: (category) ->
    num = if trig then 2 else 1
    doubleBuffers["#{category}#{num}"]

  getWeights: (data) ->
    result   = []
    weights  = avs.readPixels(@getOutBuf('clust'))
    curClust = 0
    buffer   = []
    for x in weights by 4
      buffer.push x / 255.0
      if curClust == conf.clust - 1
        result.push buffer
        buffer = []
        curClust  = 0
      else
        curClust += 1
    result

  generateRandomWeights: ->
    randomData = []
    for x in [0...size[0]]
      for y in [0...size[1]]
        sum = 1.0
        for k in [0...(conf.clust - 1)]
          perc = Math.random() * sum
          if perc > sum then perc = sum
          randomData.push perc
          randomData.push 0
          randomData.push 0
          randomData.push 0
          sum -= perc
        randomData.push sum
        randomData.push 0
        randomData.push 0
        randomData.push 0
    randomData

  readBuffer: (buf) ->
    avs.readPixels buf

  debugOutputWeights: ->
    for weights in @getWeights()
      console.log _.map(weights, (x) -> x.toFixed(4)).join('\t')
    console.log '---'
