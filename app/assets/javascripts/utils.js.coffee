window.Utils = {

  alignToTexture: (sizex) ->
    x = 1
    while (x*x) < sizex then x *= 2
    [x, x]

  fillRestWith: (arr, length, data=[0, 0, 0, 0]) ->
    while arr.length < length then arr.push data

  shiftExtendVector: (origin, x) ->
    [x[0] - origin[0], x[1] - origin[1], 0]

  cross: (a, b) ->
    cross = [
      a[1] * b[2] - a[2] * b[1],
      a[2] * b[0] - a[0] * b[2],
      a[0] * b[1] - a[1] * b[0]
    ]

  crossComparator: (origin) -> (x, y) ->
    a = Utils.shiftExtendVector origin, x
    b = Utils.shiftExtendVector origin, y
    cross = Utils.cross(a, b)
    
    if (cross[2] > -1e-6 and cross[2] < 1e-6) then 0 else
      if (cross[2] > 0) then 1 else -1
}
