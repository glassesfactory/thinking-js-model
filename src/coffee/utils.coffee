###
  よく使うローレベルな関数集
###

define [], ->
  do(window)->
    ObjProto       = Object.prototype
    ArrayProto     = Array.prototype
    nativeForEach  = ArrayProto.forEach
    nativeMap      = ArrayProto.map
    nativeIndexOf  = ArrayProto.indexOf
    nativeSome     = ArrayProto.some
    nativeFilter   = ArrayProto.filter
    concat         = ArrayProto.concat
    slice          = ArrayProto.slice
    nativeKeys     = ObjProto.keys
    hasOwnProperty = ObjProto.hasOwnProperty
    nativeIsArray  = Array.isArray
    nativeOwn      = ObjProto.getOwnPropertyNames

    group = (behavior)->
      return (obj, value, context)->
        result = {}
        iterator = if value == null then gy.identity else gy.lookupIterator(value)
        gy.each(obj, (value, index)->
          key = iterator.call(context, value, index, obj)
          behavior result, key, value
        )
        return result

    gy =
      _inArray:( elem, array )->
        i = 0
        len = array.length
        while i < len
          if array[ i ] is elem
            return i
          i++
        return -1


      ###
        check obj type is functuion
        from underscore.js
      ###
      isFunc:(obj)->
        typeof obj is 'function'

      isEmpty:(obj)->
        if obj == null
          return true
        if gy.isArray(obj) or gy.isString(obj)
          return obj.length is 0
        for key of obj
          if gy.has(obj, key)
            return false
        return true

      isArray: nativeIsArray or (obj)->
        return toString.call(obj) is '[object Array]'

      isString:(obj)->
        return toString.call(obj) is '[object String]'


      isString:(obj)->


      findWhere:(list, properties)->
        gy.where(list, properties, true)

      where:(list, properties, first)->
        if gy.isEmpty(properties)
          return if first then 0 else []
        return gy[if first then 'find' else 'filter'](list, (value)->
          for key of properties
            if properties[key] isnt value[key]
              return false
          return true
          )

      ###
        collection to uniq.
        from underscore.js
      ###
      uniq:(array, isSorted, iterator, context)->
        if gy.isFunc isSorted
          context = iterator
          iterator = isSorted
          isSorted = false

        initial =  if iterator then gy.map(array, iterator, context) else array
        results = []
        seen = []
        gy.each initial, (value, index)->
          if (if isSorted then (!index or seen[seen.length - 1] isnt value) else not gy.contains(seen, value))
            seen.push value
            results.push array[index]

        return results

      filter:(obj, iterator, context)->
        results = []
        if obj is null
          return results
        if nativeFilter && obj.filter is nativeFilter
          return obj.filter(iterator, context)
        gy.each obj, (value, index, list)->
          results.push value if iterator.call context, value, index, list

        return results


      find:(obj, iterator, context)->
        result = null
        gy.any(obj, (value, index, list)->
          if iterator.call(context, value, index, list)
            result = value
            return true
        )
        return result


      contains:(obj, target)->
        if obj == null
          return false
        if nativeIndexOf and obj.indexOf is nativeIndexOf
          return obj.indexOf(target) != -1
        return gy.any obj, (value)->
          return value is target

      diff:(array)->
        rest = concat.apply(ArrayProto, slice.call(arguments, 1))
        return gy.filter(array, (value)->
          return !gy.contains(rest, value)
        )


      each:(obj, iterator, context)->
        if obj == null
          return
        if nativeForEach && obj.forEach is nativeForEach
          obj.forEach(iterator, context)
        else if obj.length is +obj.length
          i = 0
          len = obj.length
          while i < len
            if iterator.call(context, obj[i], i, obj) is breaker
              return
            i++
        else
          keys = gy.keys(obj)
          i = 0
          len = keys.length
          while i < len
            if iterator.call(context, obj[keys[i]], keys[i], obj) is breaker
              return
            i++

      map:(obj, iterator, context)->
        results = []
        if obj == null
          return results
        if nativeMap and obj.map is nativeMap
          return obj.map(iterator, context)
        gy.each obj, (value, index, list)->
          results.push iterator.call(context, value, index, list)
        return results

      keys:nativeKeys || (obj)->
        if obj isnt Object(obj)
          throw new TypeError('Invalid object')
        keys = []
        for key of obj
          keys.push(key) if gy.has(obj, key)
        return keys


      indexBy : group (result, key, value)->
        result[key] = value

      lookupIterator: (value)->
        return if gy.isFunc(value) then value else (obj)->
          return obj[value]


      ###
        指定した key が与えられたオブジェクトに存在するかどうか
      ###
      has:(obj, key)->
        return hasOwnProperty.call(obj, key)


      any:(obj, iterator, context)->
        iterator || (iterator = gy.identity)
        result = false
        if obj == null
          return result
        if nativeSome && obj.some is nativeSome
          return obj.some(iterator, context)
        gy.each obj, (value, index, list)->
          if (result || (result = iterator.call(context, value, index, list)))
            return breaker
        return !!result

      _$notNull:($jqObj)->
        unless $jqObj
          return false
        else if $jqObj.length < 1
          return false
        return true

      identity:(value)->
        return value


      executeByString:(str)->
        target = window
        target = target[propName] for propName in str.split "."
        return target



      ###
        対象オブジェクトから指定した key の値を取得する
      ###
      getObjectValue:(obj, key)->
        if hasOwnProperty.call obj, key
          return obj[key]
        else
          return null



      ###
        対象が持っているプロパティ一覧を取得する
      ###
      getPropNames:(target)->
        props = []
        o = target
        while o
          props = props.concat Object.getOwnPropertyNames o
          o = Object.getPrototypeOf o
        props = gy.uniq props
        return props


      ###
        プロパティ一覧を取ってくる
      ###
      getOwnPropertyNames: nativeOwn || (obj)->
        arr = []
        arr.push k if obj.hasOwnProperty(k) for k of obj
        return arr


      ###
        指定された型から適切なデフォルト値を取得する
      ###
      getDefault:(type)->
        type = type.toLowerCase()
        if type is "function" or type is "object"
          return null
        if type is "number" or type is "int"
          return 0
        if type is "array"
          return []
        if type is "string"
          return ""
        if type is "date"
          return new Date()

      _strToFilterFunc:(str)->
        console.log str

    do ->
      gy.objProps = gy.getPropNames Object
      #super も対象外にする
      gy.objProps.push "__super__"

    window.gy = gy
  return gy