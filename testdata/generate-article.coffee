###
  article 用ダミーデータ生成
###

dummyText = ["hya-", "わなげwanageWANAGE", "おなかすいた", "あばばばばばば", "たにし", "ふうううう", "abcdefghijk（､_'' (o)_: ( [三] ) _(o)`_, :::）　うわぁぁぁああ！！", "んん?", "デース", "ヘーイ提督ぅ", "くおえうえーーーるえうおおおｗｗｗ", "重雷装巡洋艦", "北上だよー"]
dummyLen  = dummyText.length


db.createCollection "articles"


generateRundumTxt =(min_count)->
  num = Math.random() * dummyLen + min_count | 0
  i = 0
  result = ""
  while i < num
    index = Math.random() * dummyLen | 0
    result += dummyText[index] + "\n"
    i++
  return result

i = 0
len = 500
while i < len
  title = generateRundumTxt(3)
  body  = generateRundumTxt(5)
  more  = generateRundumTxt(10)

  article =
    id         : i
    title      : title
    body       : body
    more       : more
    created_at : new Date()
    updated_at : new Date()

  db.articles.save(article)
  i++
