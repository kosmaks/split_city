class window.Bitonic

  texVertex = """
  attribute vec2 vertex;
  varying vec2 index;

  void main() {
    index.x = (vertex.x > 0.) ? 1. : 0.;
    index.y = (vertex.y > 0.) ? 1. : 0.;
    gl_Position = vec4(vertex, 0., 1.);
  }
  """

  helper = -> """
  precision mediump float;
  \#define AT(arr, x, y) texture2D(arr, vec2(x / #{sizex()}, y / #{sizey()})

  \#define X_TO_TEX(val) (val / #{sizex()})
  \#define Y_TO_TEX(val) (val / #{sizey()})
  \#define X_TO_PIX(val) floor(val * #{sizex()})
  \#define Y_TO_PIX(val) floor(val * #{sizey()})

  \#define TO_PIX(vec) vec2(X_TO_PIX(vec.x), Y_TO_PIX(vec.y))
  \#define TO_TEX(vec) vec2(X_TO_TEX(vec.x), Y_TO_TEX(vec.y))

  vec2 coordShift(float shift, vec2 src) {
    vec2 index = TO_PIX(src);
    float wide = index.x + shift;
    float indexX = mod(wide, #{sizex()});
    float indexY = index.y + floor(wide / #{sizex()});
    if (indexY > #{sizey()}) indexY -= #{sizey()};
    else if (indexY < 0.) indexY += #{sizey()};
    return TO_TEX(vec2(indexX, indexY));
  }

  \#define DIR_CMP(forward, a, b) (forward == (a < b) ? a : b)
  """

  # initializer data
  avs  = null
  size = null
  conf = {}

  # programms
  sortProg = null
  mergeProg = null

  # buffer
  buffer1 = null
  buffer2 = null

  # shader helpers
  fix = (x) -> x.toFixed 10
  sizeM = -> fix size[0] * size[1]
  sizex = -> fix size[0]
  sizey = -> fix size[1]

  trig = false

  constructor: (options = {}) ->
    avs = options.avs ? new AVS options.elem

  configure: (options = {}) ->
    size = [2, 2]

    buffer1 = avs.createFramebuffer {
      size: size,
      data: new Float32Array([
        0.5, 0, 0, 0,
        0.3, 0, 0, 0,
        0.8, 0, 0, 0,
        0.1, 0, 0, 0,
      ])
    }
    buffer2 = avs.createFramebuffer {
      size: size
    }

    trig = false

    sortProg = avs.createProgram {
      vertex: texVertex,
      fragment: """
      #{helper()}

      varying vec2 index;
      uniform float spread;
      uniform sampler2D src;
      vec4 current = texture2D(src, index);

      void main() {
        vec2 native = TO_PIX(index);
        float curr = native.x + native.y * #{sizex()};
        
        bool even = mod(floor(curr / spread), 2.) == 0.;
        vec2 bCoord = coordShift((even ? 1. : -1.) * spread, index);

        float a = current.x;
        float b = texture2D(src, bCoord).x;

        // fill result
        gl_FragColor = current;
        gl_FragColor.x = DIR_CMP(even, a, b);
      }
      """
    }

    mergeProg = avs.createProgram {
      vertex: texVertex,
      fragment: """
      #{helper()}
        
      varying vec2 index;
      uniform sampler2D src;
      uniform float count;
      vec4 current = texture2D(src, index);

      float blockSize = #{sizeM()} / count;

      void main() {
        vec2 native = TO_PIX(index);
        float curr = native.x + native.y * #{sizex()};
        bool even = mod(floor(curr / (blockSize / 2.)), 2.) == 0.;

        float shift = (blockSize - 1.) - (2. * mod(curr, blockSize));
        vec2 bCoord = coordShift(shift, index);

        float a = current.x;
        float b = texture2D(src, bCoord).x;

        // fill result
        gl_FragColor = current;
        gl_FragColor.x = DIR_CMP(even, a, b);
      }
      """
    }

  sort: ->
    merge = sizeM() / 2
    while merge >= 1
      avs.pass mergeProg, @getOutBuf(), src: @getInBuf().texture, (b) ->
        b.prog.sendFloat('count', merge)
      trig = not trig

      sort = sizeM() / merge / 4
      while sort >= 1
        avs.pass sortProg, @getOutBuf(), src: @getInBuf().texture, (b) ->
          b.prog.sendFloat('spread', sort)
        trig = not trig

        sort /= 2
      merge /= 2

  getInBuf: -> if trig then buffer2 else buffer1

  getOutBuf: -> if trig then buffer1 else buffer2

  debugOutput: ->
    console.log _.map avs.readPixels(@getInBuf()), (x) -> x / 255.0
