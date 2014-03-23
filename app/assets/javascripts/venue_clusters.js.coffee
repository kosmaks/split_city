class window.VenueClusters
  WORKER_URL = "/assets/workers/cluster_worker.js"
  worker = null

  opts = {
    debug: true
  }

  constructor: ->
    worker = new Worker WORKER_URL

  configure: (options = {}) ->
    opts.venues  = options.venues ? []
    opts.weights = options.weights ? []

  process: (callback = ->) ->
    worker.onmessage = (x) ->
      callback x.data
      worker.onmessage = (->)
    worker.postMessage opts
