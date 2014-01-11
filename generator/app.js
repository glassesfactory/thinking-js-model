(function() {
  var Article, ArticleSchema, HOST, News, Schema, Search, app, db, doConfigure, express, http, jsonRouter, mongoose, path, server, url;

  express = require('express');

  http = require('http');

  path = require('path');

  url = require('url');

  doConfigure = require('./configure');

  jsonRouter = require('./express-json-router');

  HOST = "http://127.0.0.1:3000/";

  app = express();

  doConfigure(app, {});

  jsonRouter(app, "../routes.json");

  server = http.createServer(app).listen(app.get('port'), function() {});

  mongoose = require("mongoose");

  Schema = mongoose.Schema;

  ArticleSchema = new Schema({
    id: Number,
    title: String,
    body: String,
    more: String,
    created_at: Date,
    updated_at: Date
  });

  mongoose.model("Article", ArticleSchema);

  Article = null;

  News = null;

  Search = null;

  mongoose.connect("mongodb://localhost/static-model");

  db = mongoose.connection;

  db.on('error', console.error.bind(console, 'connection error:'));

  db.once('open', function() {
    console.log("Connected to 'static-model' database");
    return Article = mongoose.model('Article');
  });

  app.get('/article', function(req, res) {
    return Article.find({}, null, {}, function(err, results) {
      if (err) {
        return res.send("oooooo");
      } else {
        return res.json(results);
      }
    });
  });

  /*
  ----------------------
    各ハンドラごとに特殊な処理をしたい場合は
    直接以下にルーティングを定義していく
  ----------------------
  */


  /*
    インデックス
  */


}).call(this);
