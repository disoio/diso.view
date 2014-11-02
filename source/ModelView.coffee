# Local dependencies
# ------------------
# [View](./View.html)  
View = require('./View')

# throwError
# ----------
# Convenience method for throwing errors in this class
throwError = (msg)->
  throw new Error("diso.view.Model: #{msg}")

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
  # A. 'model' arg
  # B. <model_name> in its data arg if that has been set
  #    in the child class
  # C. model attribute set statically in child class' body
  constructor : (args)->
    unless args.data
      args.data = {}

    model = null

    model_in_args = ('model' of args)

    if model_in_args
      model = args.model
      delete args.model

    if (@model_name and (@model_name of args.data))
      if model_in_args
        throwError("Can't pass model arg and named model in data")
      
      # when custom model name has been set in child class
      model = args.data[@model_name]
    
    # its also possible that the 'model' accessor property defined 
    # below can be overriden in child class in which case @model 
    # will be the actual model rather than property lookup 
    # either way @model should at this point return something 
    # either set above or in the child class. otherwise throw error

    unless model
      throwError("Missing model in #{@constructor.name}")

    super(args)
    model_name = @_modelName()
    @[model_name] = model

# We need to access the model indirectly so as to support
# the different ways of specifying it in constructor / child class
Object.defineProperty(ModelView.prototype, 'model', {
  get: ()->
    @[@_modelName()]

  set: (val)->
    @[@_modelName()] = val
})

    
module.exports = ModelView