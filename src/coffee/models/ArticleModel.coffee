define [
  "Config"
  "models/BaseModel"
],(
  Config
  BaseModel
)->
  "use strict"
  class ArticleModel extends BaseModel
    @TABLE_NAME : "ArticleModel"
    ###
      @static
      テーブル構造
    ###
    @DDL :
      id :
        type : "int"
        key  : "primary key"
        readOnly : true
      title :
        type : "string"
      body :
        type : "string"
      more :
        type : "string"
      created_at :
        type : "date"
      updated_at :
        type : "date"

    constructor:(initObj)->
      super(initObj)

  do ->
    BaseModel.extends ArticleModel
  return ArticleModel
