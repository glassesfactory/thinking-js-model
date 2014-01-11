define [
  "Config"
  "configs/ORMConfig"
  "storage/MemStorage"
  "QueryParser"
],(
  Config
  ORMConfig
  MemStorage
  QueryParser
)->
  "use strict"
  class BaseModel
    @DDL : []
    kls  : null

    @TABLE_NAME : null

    #格納するストレージクラス
    @storageKls    : MemStorage
    #クエリ
    @queryInstance : null
    #クエリを蓄積する
    @queryQueue    : []
    #サーバーの URL
    @url           : null
    #クエリを遅延実行するかどうか
    @lazyQuery     : true

    #データの実体
    _diTmp : {}


    constructor:(initObj)->
      #クエリを遅延実行するかどうか
      @lazyQuery = initObj?.lazyQuery?
      @lazyQuery ?= ORMConfig.lazyQuery

      #クラスへの参照
      @kls ?= @.constructor
      @_diTmp = {}
      @_bindDDL()
      #プロパティの初期値が与えられていればバインドする
      @_bindProperty(initObj)


    @limit:(limit)->
      unless limit
        throw new Error "引数がたりん"
      @fetch(limit)


    ###
      結果を返す
      @param limit 件数
    ###
    @fetch:(limit, force)->
      #一度も保存されていない
      result = []
      #今までクエリが実行されてなければコレクションを取得してくる
      @queryInstance ?= @storageKls.getInstance().fetch(@)
      #遅延実行モードならこのタイミングでクエリを全て実行する
      if @lazyQuery
        q() for q in @queryQueue
        @queryQueue = null

      #limit が指定されていたら指定された件数にする
      if limit
        @queryInstance = @queryInstance.slice 0, limit
      result = @queryInstance.slice()
      #クエリ用インスタンスを削除する
      @queryInstance = null
      models = []
      for data in result
        models.push new @(data)
      return models


    ###
      @static
      条件でフィルタリング
      @param filter フィルター条件式
        function or String
        :type: function
          ORMModel.filter (obj)=>
            return obj.id > 4
        :type: String
          ORMModel.filter "id > 4"
    ###
    @filter:(filter)->
      #filter が条件文字列だったら function に展開する
      exec = gy.filter
      if typeof filter is "string"
        filter = QueryParser.parse filter
        # exec = gy.where
      q =()=>
        @queryInstance = exec @queryInstance, filter
        return @queryInstance
      #クエリが遅延発行かどうか
      if @lazyQuery
        @queryQueue ?= []
        @queryQueue.push q
      else
        #なければストレージから取ってくる
        @queryInstance ?= @storageKls.getInstance().fetch(@)
        @queryInstance = q()

      return @


    ###
      @static
      並びかえしる
      @param orderBy
        :accending:
          ORMModel.order("propName")
        :deccending:
          ORMModel.order("-propName")
    ###
    @order:(orderBy)->
      #降順か昇順か
      ace = true
      order = orderBy
      if orderBy[0] is "-"
        ace = false
        order = orderBy.slice 1, orderBy.length
      #実行したいやつを関数化する
      q = ()=>
        obj = gy.indexBy @queryInstance, order
        tmp = []
        for k of obj
          tmp.push obj[k]
        unless ace
          @queryInstance = @queryInstance.reverse()
        return @queryInstance

      if @lazyQuery
        @queryQueue ?= []
        @queryQueue.push q
      else
        @queryInstance ?= @storageKls.getInstance().fetch(@)
        @queryInstance = q()

      return @


    ###
      1件取得する
    ###
    @get:(id_or_query)->
      @queryInstance ?= @storageKls.getInstance().fetch(@)
      query = {}
      console.log @key
      query[@key] = id_or_query
      console.log query
      result = gy.where @queryInstance, query
      if result.length > 0
        return new @(result[0])
      return null


    ###
      件数を返す
    ###
    @len:()->
      #まだクエリ化されていなければ全件の件数を返す
      if not @queryInstance and @queryQueue.length < 1
        return @storageKls.getInstance().fetch(@).length
      if @lazyQuery
        if @queryQueue
          return @queryQueue.length
      else
        return @queryInstance.length


    ###
      保存する
      オプションを何に使うかは考えていない
    ###
    save:()=>
      #TABLE_NAME が設定されていない場合はクラス名を勝手に取ってくる
      unless @kls.TABLE_NAME
        proto = target.__proto__
        cnst = proto.constructor
        @kls.TABLE_NAME = cnst.name
      #ストレージに格納
      @kls.storageKls.getInstance().add @_diTmp, @kls.TABLE_NAME, @kls.key
      return


    ###
      更新する
    ###
    update:()=>
      @kls.storageKls.getInstance().update @_diTmp, @kls.TABLE_NAME, @kls.key


    ###
      削除する
    ###
    del:()=>
      @kls.storageKls.getInstance().remove @_diTmp, @kls.TABLE_NAME, @kls.key



    ###*
      @private
      テーブル構造をバインドする
    ###
    _bindDDL:()=>
      for k of @kls.DDL
        v = @kls.DDL[k]
        @kls.key = k if v.hasOwnProperty("key") and not @kls.key

        #型指定がなければオブジェクトにする
        v.type      = "object" unless v.hasOwnProperty "type"
        #読み込みオンリーが指定されてなければ書き込みを許可する
        v.readOnly = false unless v.hasOwnProperty "readOnly"
        #デフォルト値の設定
        v.default = gy.getDefault(v.type) unless v.hasOwnProperty "default"

        #インスタンスにプロパティを設定する
        do(k)=>
          descripter = {
            hoge : "huhuu"
            enumerable : true
            get : ()=>
              return @_diTmp[k]
          }
          unless v.readOnly
            descripter["set"] = (val)=>
              @_diTmp[k] = val
          Object.defineProperty @, k, descripter


      unless @kls.key
        throw new Error("Model を扱うには key の指定が必要です。")
      #Setter とプロパティの削除を封印
      Object.seal @


    ###
      プロパティ一覧から排除する者達
    ###
    _bindIgnores:()=>
      #うーん
      @properties = []
      props = gy.getPropNames @
      props = gy.diff props, StrictModel.ignores

      for prop in props
        @properties.push prop if typeof @[prop] isnt "function"
      return


    ###
      初期値のバインド
    ###
    _bindProperty:(properties)=>
      for k of properties
        if @.hasOwnProperty(k)
          @_diTmp[k] = properties[k]
      return


    ###
      現在のデータを JSON 文字列にする
    ###
    toJSON:()=>
      return JSON.stringify @toObject()


    ###
      現在のデータをオブジェクトにする
    ###
    toObject:()=>
      obj = {}
      for prop in @propNames
        obj[prop] = @[prop]
      return obj


    ###
      ターゲットとなるクラスに
      このクラスが保持するクラスメソッドを実装する
    ###
    @extends:(kls)->
      props = gy.getPropNames @
      props = gy.diff(props, gy.objProps)

      for name in props
        kls[name] = @[name] if typeof @[name] is "function" and name not in kls

      kls.storageKls    = MemStorage
      kls.queryQueue    = null
      kls.queryInstance = null
      kls.lazyQuery     = ORMConfig.lazyQuery
      # kls.isForce       = false
      # kls.gatewayKls    = APIGateway.constructor
      # kls.currentMin    = null
      # kls.currentMax    = null
      # kls.isMax         = false
      return

