View = require('./View')

class ModelView extends View
  model_name : 'model'
  
  constructor : ()->
    super
    
    @[@model_name] = @data.model

  model : ()->
    @[@model_name]
    
module.exports = ModelView