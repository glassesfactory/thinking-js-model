/*
  JSON からルーティングをバインドする
*/


(function() {
  var jsonRouter;

  jsonRouter = function(app, path) {
    var routes, routesArray, routing, templateMap, templateTitle, _i, _len, _results;
    routes = require(path);
    routesArray = routes.routes;
    templateMap = {};
    templateTitle = {};
    _results = [];
    for (_i = 0, _len = routesArray.length; _i < _len; _i++) {
      routing = routesArray[_i];
      templateMap[routing.url] = routing.template;
      templateTitle[routing.url] = routing.title;
      _results.push(app.get(routing.url, function(req, res) {
        return res.render(templateMap[req.url], {
          pretty: true,
          title: templateTitle[req.url]
        });
      }));
    }
    return _results;
  };

  module.exports = jsonRouter;

}).call(this);
