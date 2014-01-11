###
  JSON からルーティングをバインドする
###
jsonRouter =(app, path)->
  routes = require path
  routesArray = routes.routes
  templateMap = {}
  templateTitle = {}
  for routing in routesArray
    templateMap[routing.url] = routing.template
    templateTitle[routing.url] = routing.title
    app.get routing.url, (req, res)->
      res.render templateMap[req.url], {pretty:true, title:templateTitle[req.url]}

module.exports = jsonRouter