express = require('express')
http = require('http')
path = require('path')
url = require('url')

doConfigure = require('./configure')
jsonRouter  = require('./express-json-router')

# HOST = "http://houston.kageya.ma/"
HOST = "http://127.0.0.1:3000/"

app = express()
# image_path など全テンプレート内共通で呼びたい変数をこうやって定義する
#app のコンフィグを設定する
doConfigure app, {}
jsonRouter app, "../routes.json"
server = http.createServer(app).listen app.get('port'), ()->
#ルーティングを json からバインドする


mongoose = require "mongoose"
Schema = mongoose.Schema
ArticleSchema = new Schema
  id         :  Number
  title      : String
  body       : String
  more       : String
  created_at : Date
  updated_at : Date

mongoose.model "Article", ArticleSchema

Article = null

News = null
Search = null

mongoose.connect "mongodb://localhost/static-model"

db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error:')
db.once('open', ()->
  console.log("Connected to 'static-model' database");
  Article = mongoose.model('Article')
)

app.get '/article', (req, res)->
  Article.find {}, null, {}, (err, results)->
    if err
      res.send "oooooo"
    else
      return res.json(results)




###
----------------------
  各ハンドラごとに特殊な処理をしたい場合は
  直接以下にルーティングを定義していく
----------------------
###

###
  インデックス
###
#test
# app.get '/', (req, res)->
  # res.render 'index'
#
