class window.ClustStatsView extends Backbone.View
  el: '#clust-stats-layout'

  initialize: ->
    @regions = @$el.find('.regions')

    split_city.app.on 'sync', @update, @
    @update()

  update: ->
    clust = split_city.app.getClusters()
    return unless clust?
    @clear()
    for k, info of clust
      @addInfo k, info

  clear: ->
    @regions.html ''

  addInfo: (k, info) ->
    chart = new CategoriesChartView {
      title: info.category.name
      k: k
      info: info
      categories: _.map(info.categories, (cat) =>
        [cat.name, 100.0 * cat.count / info.categoriesCount]
      )
    }
    @regions.append chart.$el
    chart.render()
