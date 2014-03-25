#= require ./yandex_maps

class window.MapView extends Backbone.View
  el: '#map-layout'

  events: {
    'slide .clusters-count': 'changeClusterCount'
    'slide .m-parameter': 'changeM'
    'click .do-redraw': 'forceRefresh'
    'change .do-show-regions': 'update'
    'change .do-show-venues': 'update'
    'change .do-show-venue-points': 'update'
  }

  initialize: ->
    @$el.find('.clusters-count').slider {
      formater: (x) -> Math.pow(2, x) + " clusters"
    }
    @$el.find('.m-parameter').slider()

    @sourcesContainer = @$el.find('.sources-container')
    @showRegions = @$el.find('.do-show-regions')
    @showVenues = @$el.find('.do-show-venues')
    @showVenuePoints = @$el.find('.do-show-venue-points')

    @initVenueSources()

    @map = new YandexMapsView {
      element: "map"
    }
    @map.render =>
      split_city.app.on 'sync', @update, @
      @update()

  initVenueSources: ->
    @venueSourceViews = _.map(SPLIT_CITY.venue_sources, (source) =>
      view = new VenueSourceView source
      view.on 'click', (self) =>
        for otherView in @venueSourceViews
          otherView.setActive false
        self.setActive true
        split_city.app.receiveVenues self.route
    )
    @sourcesContainer.html ''
    for view in @venueSourceViews
      @sourcesContainer.append view.$el
    @venueSourceViews[0].setActive true

  navigatedTo: -> @active = true; @update()
  navigatedFrom: -> @active = false

  update: ->
    clust = split_city.app.getClusters()
    return if not @active or not clust?
    @map.clear()
    for k, info of clust
      if @showRegions.is(':checked')
        @map.drawCluster k, info
      if @showVenues.is(':checked')
        @map.drawLines k, info
      if @showVenuePoints.is(':checked')
        for venue in info.venues
          @map.drawVenue k, info, venue

  tryInitMap: ->

  changeClusterCount: (e) ->
    split_city.app.setNumOfClusters e.value

  changeM: (e) ->
    split_city.app.setM e.value

  forceRefresh: ->
    split_city.app.forceRefresh()

class window.VenueSourceView extends Backbone.View

  template: -> "<a href='#' class='list-group-item'></a>"

  events: {
    'click':'click'
  }
  
  initialize: (options) ->
    @name = options.name ? SPLIT_CITY.venueSourceViews[0].name
    @route = options.route ? SPLIT_CITY.venueSourceViews[0].route
    @$el = $ @template()
    @$el.text @name

  click: -> @trigger 'click', @

  setActive: (flag) ->
    if flag then @$el.addClass 'active'
    else @$el.removeClass 'active'
