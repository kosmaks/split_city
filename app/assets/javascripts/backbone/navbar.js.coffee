#= require ./yandex_maps

class window.NavbarView extends Backbone.View
  el: '#navbar'

  initialize: ->
    split_city.app.on 'loading', @loading, @
    split_city.app.on 'loaded', @loaded, @

    @loadingEl = @$el.find('.loading')
    @progress = @loadingEl.find('span')

    if split_city.app.isLoading() then @loading("data")
    else @loaded()

  loading: (x) ->
    @progress.text x
    @loadingEl.finish().fadeIn('fast')

  loaded: ->
    @loadingEl.finish().fadeOut('fast')
