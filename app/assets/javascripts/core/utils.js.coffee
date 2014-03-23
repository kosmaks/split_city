window.Utils = {

  formatPow2: (x) ->
    Math.pow(2, x)

  alignToTexture: (sizex) ->
    x = 1
    while (x*x) < sizex then x *= 2
    [x, x]

  fillRestWith: (arr, length, data=[0, 0, 0, 0]) ->
    while arr.length < length then arr.push data

  indexToColor: (index, extra='') ->
    switch "#{index}"
      when '0'  then "#000000" + extra
      when '1'  then "#ff0000" + extra
      when '2'  then "#00ff00" + extra
      when '3'  then "#ffff00" + extra
      when '4'  then "#0000ff" + extra
      when '5'  then "#ff00ff" + extra
      when '6'  then "#00ffff" + extra
      when '8'  then "#ffffff" + extra
      when '9'  then "#0000aa" + extra
      when '10' then "#ff00aa" + extra
      when '11' then "#00ffaa" + extra
      when '12' then "#ffffaa" + extra
      when '13' then "#aa00ff" + extra
      when '14' then "#ffaaff" + extra
      when '15' then "#aaffff" + extra
      when '16' then "#ffffaa" + extra

}
