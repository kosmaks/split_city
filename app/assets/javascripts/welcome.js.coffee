$ ->
  window.split_city = {
    app: new Application()
    router: new Router()
  }

  Backbone.history.start()
  split_city.app.run()
