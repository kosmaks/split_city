class window.Profiler

  checkpoint = null
  startpoint = null
  points = null

  begin: ->
    checkpoint = (new Date).getTime()
    startpoint = checkpoint
    points = []

  checkpoint: (title="") ->
    points.push {
      title: title
      time: ((new Date).getTime() - checkpoint)
    }
    checkpoint = (new Date).getTime()

  end: (title="") ->
    @checkpoint title
    total = (new Date).getTime() - startpoint

    console.log '--- Profile Results ---'
    for point in points
      console.log point.title + ":\t" + point.time.toFixed(5)
    console.log "Total:\t" + total.toFixed(5)
    console.log '--- - - - - - - - - ---'
