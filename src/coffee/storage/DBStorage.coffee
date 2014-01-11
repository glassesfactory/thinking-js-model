###
  Indexed Database API を使ったストレージ
###

define [
  "Config"
],(
  Config
)->
  class DBStorage
    _instance = null

    constructor:()->


    @getInstance:()->
      _instance ?= new DBStorage()
