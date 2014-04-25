View = require('./View')

class ModelView extends View
  constructor : ()->
    super
    @model = @data.model
    
module.exports = ModelView