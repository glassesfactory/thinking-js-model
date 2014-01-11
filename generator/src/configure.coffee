#モジュールのインポート
express   = require 'express'
path      = require 'path'

#設定ファイルの読み込み
setupjson = require '../setup.json'

allowCrossDomain = (req, res, next)->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE'
  res.header 'Access-Control-Allow-Headers', 'X-Requested-With, Accept, Origin, Referer, User-Agent, Content-Type, Authorization, X-Mindflash-SessionID'

  # intercept OPTIONS method
  if 'OPTIONS' is req.method
    res.send 200
  else
    next()

console.log setupjson.DIST
console.log "running dir:", process.cwd()

doConfigure =(app, config)->
  app.configure ()->
  app.set 'port', setupjson.port
  app.set 'views', path.resolve "src/jade"

  app.set 'view engine', 'jade'
  app.use express.compress()

  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.errorHandler
    dumpExceptions: true
    showTrace: true
  app.use express.static setupjson.DIST
  app.use allowCrossDomain


  app.use (req, res, next)->
    if req.headers?.accept?.indexOf("text/html") != -1 or req.url.indexOf(".htm") != -1
      prefix = setupjson.ASSET_DIR
      #相対指定
      if setupjson.use_relative_path
        relativeLen = req.path.split('/').length - 2
        i = 0
        while i < relativeLen
          prefix += "../"
          i++
      else
        prefix = "/" + prefix + "/"

      imgPath    = prefix + setupjson.IMAGE_DIR
      cssPath    = prefix + setupjson.STYLESHEET_DIR
      jsPath     = prefix + setupjson.SCRIPT_DIR

      res.locals.imgPath    = imgPath
      res.locals.cssPath    = cssPath
      res.locals.jsPath     = jsPath
    next()

module.exports = doConfigure