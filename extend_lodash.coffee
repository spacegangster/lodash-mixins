extend_lodash = (lodash) ->
  
  { assign
    bind
    clone
    isArray
    partial } = lodash

  args_as_array = ->
    res = []
    l = arguments.length
    while --l >= 0
      res.unshift(arguments[l])
    res
  assign_each = (collection, props_to_assign) ->
    for obj in collection
      (assign obj, props_to_assign)
  concat = (array1, array2) ->
    array1.concat(array2)
  
  # fastest bind on Earth
  xbind = (func, this_arg) ->
    ->
      func.apply(this_arg, arguments)

  falsee = -> false

  fbind = (func, this_arg, args...) ->
    if args
      ->
        func.apply(this_arg, (push (clone args), arguments))
    else
      ->
        func.apply(this_arg, arguments)

  find_by_first_value_as_key = (list, value_as_key, row_not_value = false) ->
    for row in list
      if row[0] == value_as_key
        if row_not_value
          return row
        else
          return row[1]
    undefined
  log  = (xbind console.log, console)
  logp = (partial fbind, console.log, console)
  logwrn = (xbind console.warn, console)
  logerr = (xbind console.error, console)
  makeExecutor = (chain) -> # TODO replace by multicall
    return null  if !chain.length
    (->((cb.apply null, arguments) for cb in chain); 0)
  multicall = (functions_to_call) ->
    real = (fn for fn in functions_to_call when ('undefined' != typeof fn))
    ->
      _real = real
      for fn in _real
        fn.apply(this, arguments)
      0
  now = Date.now
  push = (orig, extension) ->
    orig.push.apply(orig, extension)
    orig

  push_all = push
  prevent_and_stop = (e) ->
    e.preventDefault()
    e.stopPropagation()
  prevent_default = (e) -> e.preventDefault()

  read = (object, key) ->
    object[key]
  # Rewrites the values of the object by applying a special iterator to them.
  # Works with lists, hashes and rowed lists (like event tables when list is used as a hash).
  # Fault-tolerant: if key is not found in the object -- no exception is thrown.
  remap = (obj, keys, iterator) ->
    if (isArray obj)
      if !iterator # usual array
        iterator = keys
        for val, idx in obj by -1
          obj[idx] = (iterator val)
      else         # event table
        for key in keys
          for row in obj
            row[key] = (iterator row[key])
    else           # plain object
      for key in keys
        obj[key] = (iterator obj[key])
    obj
  reverse = (xbind Function::call, Array::reverse)
  stop_immediate = (e) -> e && e.stopImmediatePropagation() || false
  stop_propagation = (event) -> event.stopPropagation()
  stringify = (xbind JSON.stringify, JSON)
  unshift = (orig, ext) ->
    orig.unshift.apply(orig, ext)
    orig

  lodash.mixin({ args_as_array
                 assign_each
                 concat
                 falsee
                 fbind
                 find_by_first_value_as_key
                 log
                 logp
                 logerr
                 logwrn
                 makeExecutor
                 multicall
                 now
                 push
                 push_all
                 prevent_and_stop
                 prevent_default
                 read
                 remap
                 reverse
                 stop_immediate
                 stop_propagation
                 stringify
                 xbind } )
  lodash

if (('undefined' != typeof define) && define.amd)
  (define ['lib/lodash'], extend_lodash)
else if (('undefined' != typeof module) && module.exports)
  lodash = require('lodash')
  (extend_lodash lodash)
  module.exports = lodash
