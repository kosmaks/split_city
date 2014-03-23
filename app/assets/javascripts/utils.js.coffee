window.Utils = {

  alignToTexture: (sizex) ->
    x = 1
    while (x*x) < sizex then x *= 2
    [x, x]

  fillRestWith: (arr, length, data=[0, 0, 0, 0]) ->
    while arr.length < length then arr.push data

  centerVector: (a, b) ->
    [
      a[0] + (b[0] - a[0]),
      a[1] + (b[1] - a[1])
    ]

  distance: (a, b) ->
    x = b[0] - a[0]
    y = b[1] - a[1]
    Math.sqrt(x * x + y * y)

  shiftExtendVector: (origin, x, mult=1) ->
    [
      mult * (x[0] - origin[0]),
      mult * (x[1] - origin[1]),
      0
    ]

  cross: (a, b) ->
    cross = [
      a[1] * b[2] - a[2] * b[1],
      a[2] * b[0] - a[0] * b[2],
      a[0] * b[1] - a[1] * b[0]
    ]

  crossComparator: (origin, mult=1) -> (x, y) ->
    a = Utils.shiftExtendVector origin, x, mult
    b = Utils.shiftExtendVector origin, y, mult
    cross = Utils.cross(a, b)
    console.log cross
    
    if (cross[2] == 0) then 0 else
      if (cross[2] > 0) then 1 else -1

  grahamScan: (src) ->
    # step 1
    src = src.splice 0
    min = src[0][0]
    mini = 0
    for k, v of src
      if v[0] < min
        min = v[0]
        mini = Number k

    # step 2
    edge = src[mini]
    src.splice mini, 1
    src.sort Utils.crossComparator(edge, 1e6)

    ## step 3
    data = [edge, src[0]]
    for i in [1...src.length]
      point = src[i]
      console.log i
      while data.length > 2 and
        Utils.crossComparator(data[data.length-1], 1e6)(data[data.length-2], point) <= 0
          data.pop()
      data.push(point)
    data

}
