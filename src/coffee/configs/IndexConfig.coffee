###
  例として Index ページ用の設定を定義しておく。
  これはページごとではなく development/production など、公開環境毎に定義しても良い。
###

define [], ->
  IndexConfig:
    #読み込みを管理したい素材とか
    asset:[
      ""
    ]
