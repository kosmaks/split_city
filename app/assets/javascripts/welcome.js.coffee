$ ->
  window.split_city = {
    app: new Application
  }

  if not split_city.app.ready()
    $("#glErrorModal").modal({ backdrop: 'static', keyboard: false })

  else
    split_city.router = new Router

    Backbone.history.start()
    split_city.app.run()
