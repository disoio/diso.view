# NPM dependencies
# ------------------
# [jquery](https://github.com/jquery/jquery)  
# [shortid](https://github.com/dylang/shortid)  
# [type-of-is](https://github.com/stephenhandley/type-of-is)  
$       = require('jquery')
ShortId = require('shortid')
Type    = require('type-of-is')

# used for adding view id to the top node of the template
VIEW_REGEX = (()->
  regex_str = "^(\\s*<[\\w][\\w0-9]*)"
  new RegExp(regex_str, 'm')
)()

# Attributes used for identification and event handling
# in a view's root html node
ID_ATTR_NAME       = 'id'
BEHAVIOR_ATTR      = 'data-behavior'
BEHAVIOR_DELIMITER = ','
BEHAVIOR_SEPARATOR = ':'

# View
# ====
# This is the base class used in the view hierarchy. It is 
# responsible for rendering, behavior binding & handling, 
# and managing the subviews it contains.
class View
  # The id for this view. If not set explicitly by the child
  # an id will be generated using [shortid](https://github.com/dylang/shortid)
  id : null

  # jquery node holding this view
  _$node : null

  # memoized reference to this view's page
  _page : null

  is_page : false

  # constructor
  # -----------
  # Create the view and generate an id if neccessary
  #
  # **data** : data used to render this view
  # 
  # **user** : the user
  # 
  # *id* : set the id for this view
  constructor : (args)->
    unless args
      args = {}

    @data  = args.data || {}
    @_user = args.user

    if ('id' of args)
      @id = args.id

    unless @id
      @id = ShortId.generate()

    # The views contained within and managed by this view
    # keyed by their id 
    @_subviews = {}

  # html
  # ----
  # Called to render this view's template
  html : ()->
    html = @template()
    @_addViewId(html)

  # refresh
  # -------
  # Refresh this views content and optionally resetup it
  refresh : (resetup = true)->
    @removing()
    @_removeBehaviors()
    html = @html()
    @$node().replaceWith(html)
    @_$node = null
    if resetup
      @setup()

  # behavior
  # --------
  # This is used in the template method in child classes and 
  # returns a behavior attribute slug to be using within an html 
  # tag. The value should be an event name and a event handler 
  # name separated by a colon e.g. "click:omgClickHappen".
  #
  # The event should be a valid jQuery event and the view should
  # have a method matching the handler name. 
  #
  # When the view is setup in the client, the named event handler 
  # will be bound to the event. When the event is triggered on 
  # the element containing this behavior attribute, the handler
  # will be run. 
  #
  # **values** : a string or array of strings with the colon
  #              separated event type and handler name
  behavior : (values)->
    unless Type(values, Array)
      values = [values]

    "#{@_behaviorAttr()}=\"#{values.join(BEHAVIOR_DELIMITER)}\""

  # setup
  # -----
  # This gets called by the client in order to initialize the 
  # behavior (i.e. event) handling in this view and its subviews
  #
  # Prior to adding behaviors, it calls run, which can be 
  # overridden in child classes to perform custom logic in the 
  # client beforehand i.e. for event setup, subscription etc. 
  setup : ()->
    @run()
    @_addBehaviors()
    for id, subview of @_subviews
      subview.setup()

  # page
  # ----
  # This returns the page this view is in by going
  # up the subview hierarchy from this view until 
  # reaching the top (view with no parent), this is 
  # the page this view is in
  page : ()->
    unless @_page
      view = @
      while view.parent
        view = view.parent

      if view.is_page
        @_page = view

    @_page

  # setNode
  # -------
  # Overwrite the id of this view and update the 
  # associated dom node that contains it
  setId : (id)->
    @id     = id
    @_$node = null

  $node : ()->
    unless @_$node
      @_$node = $("##{@id}")

    @_$node

  remove : ()->
    if @parent
      @parent.removeSubview(@)
    else
      @removing()
      
    @$node().remove()

  # *SUBVIEW METHODS*
  # -----------------

  # subviews 
  # --------
  # Returns this views subviews
  subviews : ()->
    @_subviews

  # addSubview
  # ----------
  # Add a subview to this view
  addSubview : (subview)->
    unless subview.id of @_subviews
      @_subviews[subview.id] = subview
      subview.parent = @

  # addSubviews
  # ----------_
  # Add multiple subviews to this view
  addSubviews : (subviews)->
    for view in subviews
      @addSubview(view)
  
  # removeSubview
  # -------------
  # Remove a subview from this view
  removeSubview : (subview)->
    if subview.id of @_subviews
      subview.removing()
      delete @_subviews[subview.id]
      subview.parent = null
      subview._$node = null
      subview._page  = null
      subview._removeBehaviors()
  
  # removeSubviews
  # --------------
  # Remove multiple subviews from this view
  removeSubviews : (subviews)->
    for view in subviews
      @removeSubview(view)

  # removeAllSubviews
  # -----------------
  # Remove all subviews from this view
  removeAllSubviews : ()->
    for id, subview of @_subviews
      subview.removeAllSubviews()
      @removeSubview(subview)

  
  # *STUB METHODS*
  # --------------
  # These methods should implemented by child classes 

  # run
  # ---
  # This methods gets called in the setup method in the client. 
  # this after the dom is ready.. usually used for setting up 
  # event handlers, subscribing to messages via Mediator, etc.
  run : ()->
    
  # template
  # --------
  # This method should return the string of html for this view
  template : ()->
    """
    <h1>
      You need to add a <strong>template</strong> method to your view
    </h1>
    """

  # removing
  # --------
  # Called before this view is removed, giving the child class
  # a chance to clean up any resources
  removing : ()->

  # *INTERNAL METHODS*
  # ------------------

  # _addBehaviors
  # -------------
  # Find and setup behaviors for this node and all 
  # children with its behavior attr. 
  _addBehaviors : ()->
    @_addBehavior(@$node())
    
    attr = @_behaviorAttr()
    behaviors = @$node().find("[#{attr}]")
    for node in behaviors
      $node = $(node)
      @_addBehavior($node)
  
  # _addBehavior
  # ------------
  # Get and parse this node's behavior attribute and attach
  # the named method on this view as the event handler for 
  # the named event
  _addBehavior : ($node)->
    attr = @_behaviorAttr()
    values = $node.attr(attr)
    unless values
      return

    values = values.split(BEHAVIOR_DELIMITER)

    for value in values
      do (value)=>
        [event_name, handler_name] = value.split(BEHAVIOR_SEPARATOR)

        if handler_name of @
          event_name = @_namespaceEvent(event_name)
          handler = @[handler_name]
          $node.on(event_name, (event)->
            handler(
              event : event
              node  : this
              $node : $node
            )
          )
        else
          # TODO : better error handling
          console.error("no event handler on view named #{handler_name}")

  # _removeBehaviors
  # ----------------
  # Remove all the behaviors on this node
  #
  # TODO: should this probably just remove "behaviors"
  #       rather than all event handlers and there 
  #       should be some other more general method like
  #       removeEventHandlers() ?? Also probably need 
  #       to check namespacing 
  _removeBehaviors : ()->
    if @$node()
      @$node().off().find("*").off()

  # _addViewId
  # ----------
  # Add a view id to this view's rendered template
  _addViewId : (html)->
    html.replace(VIEW_REGEX, "$1 #{@_idAttr()}")
  
  # _behaviorAttr
  # -------------
  # Return the the html attribute name used for adding behaviors
  _behaviorAttr : ()->
    "#{BEHAVIOR_ATTR}-#{@id}"

  # _idAttr
  # -------
  # Returns the id attribute slug used for identifying views
  _idAttr : ()->
    "#{ID_ATTR_NAME}=\"#{@id}\""

  # _namespaceEvent
  # ---------------
  # Namespaces events with this view's  
  _namespaceEvent : (event_name)->
    "#{event_name}.#{@id}"

Object.defineProperty(View.prototype, 'user', {
  get: ()->
    @_user

  set: (user)->
    @_user = user
})
      
module.exports = View

