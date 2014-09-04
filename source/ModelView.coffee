# Local dependencies
# ------------------
# [View](./View.html)  
View = require('./View')

# ModelView
# =========
# A view subclass that is used for rendering models
class ModelView extends View

  # model_name can be overridden to make data access
  # more readable
  # TODO: should probably just reflect on the model 
  #       constructor name? 
  model_name : null
  
  # _modelName
  # ----------
  # return the model name for this view's model
  _modelName : ()->
    @model_name || '_model'

  # constructor
  # -----------
  # Create a ModelView 
  #
  # ### required args
  # When the constructor runs it must have one of the 
  # following conditions met
  # A. 'model' in its data arg
  # B. model_name in its data arg if that has been set
  #    in the child class
  # C. model attribute set statically in child class' body
  constructor : ()->
    super #sets @data to data passed to constructor

    model_name = @_modelName()

    if ('model' of @data)
      # pass model via constructor 'model' opt (also works
      # if there is a custom @model_name, in which case
      # it takes precedence of a @model_name opt
      @[model_name] = @data.model

    else if (@model_name and (@model_name of @data))
      # when custom model name has been set in child class
      @[model_name] = @data[@model_name]
    
    # its also possible that the 'model' accessor property defined 
    # below can be overriden in child class in which case @model 
    # will be the actual model rather than property lookup 
    # either way @model should at this point return something 
    # either set above or in the child class. otherwise throw error

    unless @model
      throw new Error("diso.view.Model: Missing model")

# We need to access the model indirectly so as to support
# the different ways of specifying it in constructor / child class
Object.defineProperty(ModelView.prototype, 'model', {
  get: ()->
    @[@_modelName()]

  set: (val)->
    @[@_modelName()] = val
})

    
module.exports = ModelView