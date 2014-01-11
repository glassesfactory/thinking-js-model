###
  Gyosen フレームワークパッケージモジュール
###

define [
  "utils"
], (
  gy
)->
  do(window)->
    ORMConfig =
      #サーバーとの通信に使うモジュール
      gateway    : "APIGateway"
      #ORM のクエリを遅延実行するかどうか
      lazyQuery  : false
      isSharding : true

    window.ORMConfig = ORMConfig
#   return Gyosen
