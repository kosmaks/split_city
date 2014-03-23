class window.VenueClusters
  worker = null

  opts = {
    debug: true
  }

  constructor: ->
    worker = new Worker SPLIT_CITY.workers.cluster_worker

  configure: (options = {}) ->
    opts.venues  = options.venues ? []
    opts.weights = options.weights ? []

  process: (callback = ->) ->
    worker.onmessage = (x) ->
      callback x.data
      worker.onmessage = (->)
    worker.postMessage opts
