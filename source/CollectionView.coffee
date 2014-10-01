# NPM dependencies
# ------------------
# [type-of-is](https://github.com/stephenhandley/type-of-is)  
Type = require('type-of-is')

# Local dependencies
# ------------------
# [View](./View.html)  
# [ModelView](./ModelView.html)
View      = require('./View')
ModelView = require('./ModelView')

# throwError
# ----------
# Convenience method for throwing errors in this class
throwError = (msg)->
  throw new Error("diso.view.Collection: #{msg}")

# CollectionView
# ==============
# A view subclass that is used for rendering collections
class CollectionView extends View

  # collection_name can be overridden to make data access
  # more readable
  collection_name : null

  # _collectionName
  # ----------
  # return the collection name for this view's collection
  _collectionName : ()->
    @collection_name || '_collection'

  # This is set to true if this view's items are View 
  # subclasses. Used to determine how to render those items
  item_is_view : false

  # constructor
  # -----------
  # Create a CollectionView
  #
  # ### required args
  # When the constructor runs it must have one of the 
  # following conditions met
  # A. 'collection' in its data arg
  # B. collection_name in its data arg if that has been set
  #    in the child class
  # C. child attribute set statically in child class' body
  # 
  # It must also have an item attribute that can either be 
  # A. the constructor of a View to be created and rendered
  #    for each item
  # B. a template that will called on each model in the 
  #    collection and should return a string of html

  constructor : ()->
    super #sets @data to data passed to constructor

    collection_name = @_collectionName()

    if ('collection' of @data)
      # pass collection via constructor 'collection' opt 
      # this also works if there is a custom @collection_name, in 
      # which case it takes precedence of a @model_name opt
      @[collection_name] = @data.collection

    else if (@collection_name and (@collection_name of @data))
      # when custom collection name has been set in child class
      @[collection_name] = @data[@collection_name]
    
    # its also possible that the 'collection' accessor property defined 
    # below can be overriden in child class in which case @collection
    # will be the actual collection rather than property lookup 
    # either way @collection should at this point return something 
    # either set above or in the child class. otherwise throw error

    unless @collection
      throwError("Missing collection")

    unless @item 
      throwError("Missing item template or view")
    
    @_setupItemViews()

  # addModel
  # --------
  # Add a model to this collection
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

  # refresh
  # -------
  # refresh / rerender this view
  # TODO: if removing subviews, shouldn't rerun be necc.? 
  refresh : (rerun = true)->
    @removeAllSubviews()
    @_setupItemViews()
    super(rerun)

  # *STUB METHODS*
  # --------------

  # wrapper
  # -------
  # This method will be passed this view's rendered html 
  # and can be used to optionally wrap it with some container
  wrapper : (contents)->
    """
      <div>
        #{contents}
      </div>
    """

  # itemData
  # --------
  # This can be overridden by child class to pass custom data 
  # to each item view. If the item view is a ModelView, a model 
  # attribute will be added containing the model that view is 
  # reponsible for rendering. Otherwise the element object will
  # have all its properties adding to the item data. 
  itemData : ()->
    {}

  # *INTERNAL METHODS*
  # ------------------

  # template
  # --------
  # The template for this collection view. This should in general
  # not be overriden in child classes, unless you know what you're 
  # doing. Wrapper and the item template/view should be sufficient
  # to achieve desired results. 
  template : ()->
    html = ''

    if @item_is_view
      for id, subview of @subviews()
        html += subview.html()
    else
      for element in @collection
        html += @item(element)

    @wrapper(html)

  # _setupItemViews
  # ---------------
  # If the item attribute is a View constructor, add a subview for 
  # each view in this view's collection
  _setupItemViews : ()->
    if Type.extension(@item, View)
      @item_is_view = true

      ItemView = @item
      for element in @collection
        item_data = @itemData()

        if Type.extension(ItemView, ModelView)
          item_data.model = element
        else
          for k,v of element
            item_data[k] = v

        view = new ItemView(item_data)
        @addSubview(view)

# We need to access the collection indirectly so as to support
# the different ways of specifying it in constructor / child class
Object.defineProperty(CollectionView.prototype, 'collection', {
  get: ()->
    @[@_collectionName()]

  set: (val)->
    @[@_collectionName()] = val
})

  
module.exports = CollectionView