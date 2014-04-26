View = require('./View')

class CollectionView extends View 
  constructor : (@data)->
    super(@data)

    unless @item 
      throw "CollectionView must define item View"
    
    unless 'collection' of @data
      throw "CollectionView must pass collection param to constructor"
    
    @collection = @data.collection
    
    ItemView = @item
    for model in @collection
      view = new ItemView(model : model)
      @addSubview(view)
  
  wrapper : (html)->
    html
  
  template : ()->
    html = ''
    for id, subview of @subviews
      html += subview.html()
    @wrapper(html)
  
module.exports = CollectionView