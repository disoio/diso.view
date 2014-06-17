Type = require('type-of-is')

View = require('./View')

class CollectionView extends View
  collection_name : null
  has_subviews    : false

  constructor : ()->
    super
    
    unless @item 
      throw "CollectionView must define item View"
    
    collection_name = @collection_name || 'collection'
    
    if collection_name of @data
      @collection = @data[collection_name]

    unless @collection
      throw "CollectionView must define collection or pass via constructor"
    
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
  
  template : ()->
    html = ''

    if @has_subviews
      for id, subview of @subviews
        html += subview.html()
    else
      for model in @collection
        html += @item(model)

    @wrapper(html)
  
module.exports = CollectionView