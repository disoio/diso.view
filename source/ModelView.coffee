View = require('./View')

class ModelView extends View
  model_name : 'model'
  
  constructor : ()->
    super
    
    @[@model_name] = if (@model_name of @data)
      @data[@model_name]
    else
      @data.model

  model : ()->
    @[@model_name]
    
module.exports = ModelView