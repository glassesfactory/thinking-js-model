###
  LocalStorage を使ったストレージ
###
define [
  "Config"
],(
)->
  class LSStorage
    _instance = null
    constructor:()->


    @getInstance:()->
      _instance ?= new LSStorage()

