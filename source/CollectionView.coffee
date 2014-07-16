Type = require('type-of-is')

View = require('./View')

throwError = (msg)->
  throw new Error("diso.view.Collection: #{msg}")

class CollectionView extends View
  collection_name : null
  _collectionName : ()->
    @collection_name || '_collection'

  has_subviews    : false

  constructor : ()->
    super #sets @data to data passed to constructor

    if ('collection' of @data)
      # pass collection via constructor 'collection' opt 
      # this also works if there is a custom @collection_name, in 
      # which case it takes precedence of a @model_name opt
      @collection = @data.collection

    else if @collection_name
      # when custom collection name has been set in child class
      
      if (@collection_name of @data)
        # model data can be passed via constructor data using that name
        @collection = @data[@collection_name]
      
      else if (@collection_name of @)
        # or set directly in child class implementation
        @collection = @[@collection_name]
    
    # its also possible that the 'collection' accessor property defined 
    # below can be overriden in child class in which case @collection
    # will be the actual collection rather than property lookup 
    # either way @collection should at this point return something 
    # either set above or in the child class. otherwise throw error

    unless @collection
      throwError("Missing collection")

    unless @item 
      throwError("Missing item template or view")
    
    @setupItemViews()

  setupItemViews : ()->
    if Type.extension(@item, View)
      @has_subviews = true

      ItemView = @item
      for model in @collection
        item_data = @itemData()
        item_data.model = model
        view = new ItemView(item_data)
        @addSubview(view)

  wrapper : (html)->
    html

  itemData : ()->
    {
      collection_view : @
    }

  addModel : (model)->
    unless Type(model.isEqual, Function)
      throwError("collection model missing isEqual method")
    
    index = null
    len = @collection.length
    if (len > 0)
      for i in [0..(len - 1)]
        other_model = @collection[i]
        if model.isEqual(other_model)
          index = i
          break

    if index
      @collection[index] = model
    else
      @collection.unshift(model)
  
  template : ()->
    html = ''

    if @has_subviews
      for id, subview of @subviews
        html += subview.html()
    else
      for model in @collection
        html += @item(model)

    @wrapper(html)

  refresh : (rerun = true)->
    @removeAllSubviews()
    @setupItemViews()
    super(rerun)

Object.defineProperty(CollectionView.prototype, 'collection', {
  get: ()->
    @[@_collectionName()]

  set: (val)->
    @[@_collectionName()] = val
})

  
module.exports = CollectionView