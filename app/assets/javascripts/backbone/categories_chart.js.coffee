class window.CategoriesChartView extends Backbone.View

  initialize: ->
    @info = options.info ? {
      title: "Unkonwn"
      categories: []
    }

    @$el = $ $("#categories-chart-template").html()
    @chart = @$el.find('.categories-chart')

  render: ->
    @chart.html('').highcharts {

      chart: {
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
      }

      title: text: @info.title

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
        data: @info.categories
      }]

    }
    @

  setInfo: (info) ->
    @info = info if info?
