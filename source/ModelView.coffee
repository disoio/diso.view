View = require('./View')

class ModelView extends View
  model_name : null
  _modelName : ()->
    @model_name || '_model'

  constructor : ()->
    super #sets @data to data passed to constructor

    if ('model' of @data)
      # pass model via constructor 'model' opt (also works
      # if there is a custom @model_name, in which case
      # it takes precedence of a @model_name opt
      @model = @data.model

    else if @model_name
      # when custom model name has been set in child class
      
      if (@model_name of @data)
        # model data can be passed via constructor data using that name
        @model = @data[@model_name]
      
      else if (@model_name of @)
        # or set directly in child class implementation
        @model = @[@model_name]
    
    # its also possible that the 'model' accessor property defined 
    # below can be overriden in child class in which case @model 
    # will be the actual model rather than property lookup 
    # either way @model should at this point return something 
    # either set above or in the child class. otherwise throw error

    unless @model
      throw new Error("diso.view.Model: Missing model")

Object.defineProperty(ModelView.prototype, 'model', {
  get: ()->
    @[@_modelName()]

  set: (val)->
    @[@_modelName()] = val
})

    
module.exports = ModelView