class window.Router extends Backbone.Router
  routes: {
    '': 'index'
  }

  index: ->
    console.log 'Page loaded'
