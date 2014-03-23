class window.CategoriesChartView extends Backbone.View

  initialize: (options) ->
    @title = options.title ? "Unknown"
    @categories = options.categories ? []
    @k = options.k ? 0
    @info = options.info ? {}

    @$el = $ $("#categories-chart-template").html()
    @chart = @$el.find('.categories-chart')
    @colorOnMap = @$el.find('.color-icon')
    @numOfVenues = @$el.find('.number-of-venues')
    @minWeight = @$el.find('.min-weight')
    @maxWeight = @$el.find('.max-weight')

  render: ->
    @colorOnMap.css 'background', Utils.indexToColor(@k)
    @minWeight.text (100 * @info.minWeight).toFixed(2) + "%"
    @maxWeight.text (100 * @info.maxWeight).toFixed(2) + "%"
    @numOfVenues.text @info.size

    @chart.html('').highcharts {

      chart: {
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
      }

      title: text: @title

      plotOptions: pie: {
        allowPointSelect: true
        cursor: 'pointer'
        dataLabels: {
          enabled: true
          color: '#000000'
          connectorColor: '#000000'
          format: '<b>{point.name}</b>: {point.percentage:.1f}%'
        }
      }

      series: [{
        type: 'pie'
        name: ''
        data: @categories
      }]

    }
    @

  setInfo: (info) ->
    @info = info if info?
