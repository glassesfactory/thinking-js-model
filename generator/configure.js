(function() {
  var allowCrossDomain, doConfigure, express, path, setupjson;

  express = require('express');

  path = require('path');

  setupjson = require('../setup.json');

  allowCrossDomain = function(req, res, next) {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
    res.header('Access-Control-Allow-Headers', 'X-Requested-With, Accept, Origin, Referer, User-Agent, Content-Type, Authorization, X-Mindflash-SessionID');
    if ('OPTIONS' === req.method) {
      return res.send(200);
    } else {
      return next();
    }
  };

  console.log(setupjson.DIST);

  console.log("running dir:", process.cwd());

  doConfigure = function(app, config) {
    app.configure(function() {});
    app.set('port', setupjson.port);
    app.set('views', path.resolve("src/jade"));
    app.set('view engine', 'jade');
    app.use(express.compress());
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.errorHandler({
      dumpExceptions: true,
      showTrace: true
    }));
    app.use(express["static"](setupjson.DIST));
    app.use(allowCrossDomain);
    return app.use(function(req, res, next) {
      var cssPath, i, imgPath, jsPath, prefix, relativeLen, _ref, _ref1;
      if (((_ref = req.headers) != null ? (_ref1 = _ref.accept) != null ? _ref1.indexOf("text/html") : void 0 : void 0) !== -1 || req.url.indexOf(".htm") !== -1) {
        prefix = setupjson.ASSET_DIR;
        if (setupjson.use_relative_path) {
          relativeLen = req.path.split('/').length - 2;
          i = 0;
          while (i < relativeLen) {
            prefix += "../";
            i++;
          }
        } else {
          prefix = "/" + prefix + "/";
        }
        imgPath = prefix + setupjson.IMAGE_DIR;
        cssPath = prefix + setupjson.STYLESHEET_DIR;
        jsPath = prefix + setupjson.SCRIPT_DIR;
        res.locals.imgPath = imgPath;
        res.locals.cssPath = cssPath;
        res.locals.jsPath = jsPath;
      }
      return next();
    });
  };

  module.exports = doConfigure;

}).call(this);
