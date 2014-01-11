###
  サイト全体の共通設定などをここに書いていく
  全体で浸透させたい ns がある場合はここで呼んでおく
###
define [], ->
  'use strict'
  Config =
    debug   : true
    version : 0.1
    share   :
      fb :
        appID       : "site app id"
        name        : "name"
        caption     : "caption"
        description : "description"
        link        : "http://hoge.com"
      tw :
        text : "twitter text"

