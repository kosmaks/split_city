class window.VenuesStatsView extends Backbone.View
  el: '#venues-stats-layout'

  initialize: ->
    @theaders = @$el.find('thead tr')
    @tbody = @$el.find('tbody')
    @total = @$el.find('total')
    split_city.app.on 'sync', @update, @
    @update()

  navigatedTo: -> @active = true; @update()
  navigatedFrom: -> @active = false

  update: ->
    clust = split_city.app.getClusters()
    return if not @active or not clust?
    @clear()
    for k, info of clust
      @addHeader "<span class='color-icon' style='background: #{Utils.indexToColor k};'>", "clust"
      @addInfo k, info
    @total.text @count

  addHeader: (text, type = "") ->
    @theaders.append $("<td class='#{type}'></td>").html(text)

  clear: ->
    @count = 0
    @theaders.html ''
    @tbody.html ''

    @addHeader 'Title', 'title'
    @addHeader 'Lat', 'lat'
    @addHeader 'Lng', 'lng'
    @addHeader 'Categories', 'cats'

  addInfo: (k, info) -> for venue in info.venues
    @count += 1
    tr = $ "<tr/>"
    tr.append $("<td/>").text(venue.name)
    tr.append $("<td/>").addClass('num').text(venue.lat)
    tr.append $("<td/>").addClass('num').text(venue.lng)
    tr.append $("<td/>").text(_.map(venue.categories, (x) -> x.name).join(', '))

    for weight in venue.weights
      tr.append $("<td/>").addClass('num').text (100 * weight).toFixed(2) + "%"

    @tbody.append tr
