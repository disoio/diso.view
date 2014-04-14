View = require('./View')

class CollectionView extends View
  constructor : (@data)->
    @collection = @data.collection
    ItemView = @item
    @subviews = ((new ItemView(model)) for model in @collection)
    
  container : null
    
  template : ()->
    html = (view.html() for view in @subviews).join("\n")
    if @container
      html = @container(html)
      
    html
      
module.exports = CollectionView