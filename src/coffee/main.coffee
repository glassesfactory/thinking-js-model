require [
  "Config"
  "models/ArticleModel"
], (
  Config
  ArticleModel
)->

  _successHandler = (result)->
    #save
    for data in result
      model = new ArticleModel
        id         : data.id
        title      : data.title
        body       : data.body
        more       : data.more
        created_at : data.created_at
        updated_at : data.updated_at
      model.save()

    #filtering
    # models = ArticleModel.filter("id >= 20").order("-id").len()
    # console.log models

    #get
    model = ArticleModel.get(2)
    console.log model.id, model.body

    #update
    # model.body = "艦隊のアイドルナカチャンダヨー"
    # model.update()
    # model = null
    # model = ArticleModel.get(2)
    # console.log model.body

    #delete
    # console.log model.body
    # model.del()
    # model = ArticleModel.get(2)
    # console.log model

    return

  _errorHandler = (result)->
    console.error "読み込みに失敗しますた"
    return


  $ ->
    console.log "index module"

    $.ajax
      url     : "http://localhost:3002/article"
      success : _successHandler
      error   : _errorHandler

  return