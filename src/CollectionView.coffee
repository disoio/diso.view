View = require('./View')

class CollectionView extends View
  collection_name : null
  
  constructor : ()->
    super
    
    unless @item 
      throw "CollectionView must define item View"
    
    collection_name = @collection_name || 'collection'
    
    unless collection_name of @data
      throw "CollectionView must pass collection param to constructor"
    
    @collection = @data[collection_name]
    
    ItemView = @item
    for model in @collection
      view = new ItemView(
        model           : model
        collection_view : @
      )
      @addSubview(view)
  
  wrapper : (html)->
    html
  
  template : ()->
    html = ''
    for id, subview of @subviews
      html += subview.html()
    @wrapper(html)
  
module.exports = CollectionView