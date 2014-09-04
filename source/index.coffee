# Local dependencies
# ------------------ 
# [View](./View.html)  
# [CollectionView](./CollectionView.html)  
# [Page](./Page.html)  
# [ModelView](./ModelView.html)  
View           = require('./View')
CollectionView = require('./CollectionView')
Page           = require('./Page')
ModelView      = require('./ModelView')

# Make Page, CollectionView, and ModelView accessible
# top level View export
View.Collection = CollectionView
View.Page       = Page  
View.Model      = ModelView
  
module.exports = View