$ ->
  window.split_city = {}

  split_city.app = new Application
  split_city.router = new Router

  Backbone.history.start()
  split_city.app.run()
