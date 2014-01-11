define [
  "Config"
], (
  Config
)->

  class MemStorage

    _instance = null

    @storage = {}


    constructor:()->


    ###
      ストレージからコレクションを返す
    ###
    fetch:(klsInfo)->
      name = klsInfo.name
      MemStorage.storage[name] = [] unless MemStorage.storage.hasOwnProperty name
      return MemStorage.storage[name]


    ###
      ストレージに追加する
    ###
    add:(target, name, key)->
      MemStorage.storage[name] = [] unless MemStorage.storage.hasOwnProperty name
      collection = MemStorage.storage[name]

      #キー指定がある場合は被ってないかチェックする
      if key
        unless gy.where collection, "id" : target.id, true
          collection.push target
        else
          throw new Error '#{name}::key:#{key} is must be uniq.'
      else
        collection.push target
      MemStorage.storage[name] = collection


    update:(target, name, key)->
      unless MemStorage.storage.hasOwnProperty name
        throw new Error("指定された Model は登録されていないようです。")
      collection = MemStorage.storage[name]
      console.log key, target
      i = 0
      len = collection.length
      while i < len
        item = collection[i]
        if item[key] is target[key]
          MemStorage.storage[name][i] = target
          return
        i++
      console.error "指定されたデータは格納されていません。"



    remove:(target, name, key)->
      unless MemStorage.storage.hasOwnProperty name
        throw new Error("指定された Model は登録されていないようです。")
      collection = MemStorage.storage[name]
      i = 0
      len = collection.length
      while i < len
        item = collection[i]
        if item[key] is target[key]
          MemStorage.storage[name] = collection.splice(i, 1)
          return
        i++
      console.error "指定されたデータは格納されていません。"



    @getInstance:()=>
      _instance ?= new MemStorage()

