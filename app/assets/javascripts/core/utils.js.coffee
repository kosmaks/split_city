window.Utils = {

  formatPow2: (x) ->
    Math.pow(2, x)

  alignToTexture: (sizex) ->
    x = 1
    while (x*x) < sizex then x *= 2
    [x, x]

  fillRestWith: (arr, length, data=[0, 0, 0, 0]) ->
    while arr.length < length then arr.push data

  indexToTwirl: (index) ->
    switch "#{index}"
      when '0'  then 'twirl#blueIcon'
      when '1'  then 'twirl#orangeIcon'
      when '2'  then 'twirl#darkblueIcon'
      when '3'  then 'twirl#darkgreenIcon'
      when '4'  then 'twirl#redIcon'
      when '5'  then 'twirl#darkorangeIcon'
      when '6'  then 'twirl#violetIcon'
      when '7'  then 'twirl#greenIcon'
      when '8'  then 'twirl#whiteIcon'
      when '9'  then 'twirl#greyIcon'
      when '10' then 'twirl#yellowIcon'
      when '11' then 'twirl#lightblueIcon'
      when '12' then 'twirl#brownIcon'
      when '13' then 'twirl#nightIcon'
      when '14' then 'twirl#blackIcon'

  indexToClusterTwirl: (index) ->
    switch "#{index}"
      when '0'  then 'twirl#invertedBlueClusterIcons'
      when '1'  then 'twirl#invertedOrangeClusterIcons'
      when '2'  then 'twirl#invertedDarkblueClusterIcons'
      when '3'  then 'twirl#invertedDarkgreenClusterIcons'
      when '4'  then 'twirl#invertedRedClusterIcons'
      when '5'  then 'twirl#invertedDarkorangeClusterIcons'
      when '6'  then 'twirl#invertedVioletClusterIcons'
      when '7'  then 'twirl#invertedGreenClusterIcons'
      when '8'  then 'twirl#whiteClusterIcons'
      when '9'  then 'twirl#invertedGreyClusterIcons'
      when '10' then 'twirl#invertedYellowClusterIcons'
      when '11' then 'twirl#invertedLightblueClusterIcons'
      when '12' then 'twirl#invertedBrownClusterIcons'
      when '13' then 'twirl#invertedNightClusterIcons'
      when '14' then 'twirl#invertedBlackClusterIcons'

  indexToColor: (index, extra='') ->
    switch "#{index}"
      when '0'  then "#0000ff" + extra
      when '1'  then "#ff7700" + extra
      when '2'  then "#000077" + extra
      when '3'  then "#007700" + extra
      when '4'  then "#00ff00" + extra
      when '5'  then "#774400" + extra
      when '6'  then "#ff00ff" + extra
      when '8'  then "#00ff00" + extra
      when '9'  then "#777777" + extra
      when '10' then "#ffff00" + extra
      when '11' then "#7777ff" + extra
      when '12' then "#777700" + extra
      when '13' then "#7799ff" + extra
      when '14' then "#333333" + extra

}
