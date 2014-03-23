#= require underscore
#= require backbone
#= require_tree .

class window.Application

  TIMEOUT  = 100

  avs      = null
  venues   = null
  fcm      = null
  clusters = null
  size     = 2
  m        = 2

  refresh  = true
  stop     = false
  loading  = false

  clustersWorker = new VenueClusters

  constructor: ->
    _.extend @, Backbone.Events
    avs = new AVS $("#display")[0]
    fcm = new ShaderFCM avs: avs if @ready()

  ready: ->
    avs.ready()

  receiveVenues: (source = SPLIT_CITY.venue_sources[0].route) ->
    @setLoading 'venues'
    $.get source, {}, (data) =>
      refresh = true
      venues = data
      @setLoaded()

  run: ->
    refresh = venues != null
    stop = false
    @mainLoop()
    if venues == null
      @receiveVenues()

  forceRefresh: ->
    refresh = true

  kill: ->
    stop = true

  getM: -> m
  setM: (newm) -> if newm != m
    m = newm
    refresh = true

  getNumOfClusters: -> size
  setNumOfClusters: (num) -> if num != size
    size = num
    refresh = true

  getClusters: -> clusters

  mainLoop: ->
    return if stop
    if not refresh
      setTimeout (=> @mainLoop()), TIMEOUT
    else
      refresh = false
      @update()
      setTimeout (=> @mainLoop()), TIMEOUT

  update: ->
    @setLoading 'weights'
    fcm.configure {
      clust: Math.pow(2, size)
      data: _.map(venues, (x) -> [x.lat * 1e6, x.lng * 1e6, 0, 0])
      m: m
    }
    fcm.improve() for x in [0..50]

    clustersWorker.configure {
      venues: venues
      weights: fcm.getWeights()
    }

    @setLoading 'clusters'
    clustersWorker.process (res) =>
      clusters = res.clusters
      @trigger 'sync', clusters
      @setLoaded()

  setLoading: (text) ->
    @trigger 'loading', text
    loading = true

  setLoaded: ->
    @trigger 'loaded'
    loading = false

  isLoading: -> loading
