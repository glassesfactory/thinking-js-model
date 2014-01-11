###
  クエリをぱーすする
###

define [], ->
  class QueryParser
    @parse:(queryStr)->
      strs = queryStr.split(' ')
      console.log strs
      tgt = strs[0]
      pare = parseInt(strs[2], 10)
      console.log tgt, pare
      switch strs[1]
        when "<"
          filter = (model)->
            console.log tgt
            return model[tgt] < pare
        when "<="
          filter = (model)->
            return model[tgt] <= pare
        when "=="
          filter = (model)->
            return model[tgt] is pare
        when ">"
          filter = (model)->
            return model[tgt] > pare
        when ">="
          filter = (model)->
            return model[tgt] >= pare
        when "!="
          filter = (model)->
            return model[tgt] isnt pare

      return filter