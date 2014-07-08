$    = require('jquery')
ShortId = require('shortid')
Type = require('type-of-is')

VIEW_REGEX = (()->
  regex_str = "^(\\s*<[\\w][\\w0-9]*)"
  new RegExp(regex_str, 'm')
)()

class View
  @BEHAVIOR_ATTR = 'data-behavior'
  @ID_ATTR_NAME  = 'id'
  
  constructor : (@data)->
    @data ?= {}
    
    unless @id
      @id = ShortId.generate()
      
    @subviews = {}
  
  idMap : ()->
    map = {}
    for id, subview of @subviews
      map[id] = subview.idMap()
    map
        
  behavior : (value)->
    attr = "#{@constructor.BEHAVIOR_ATTR}-#{@id}"
    if value
      "#{attr}=\"#{value}\""
    else
      attr
      
  ns : (event_name)->
    "#{event_name}.#{@id}"
    
  idAttr : ()->
    "#{@constructor.ID_ATTR_NAME}=\"#{@id}\""

  run : ()->
    @setContainer()
    @setup()
    @addBehaviors()
    for id, subview of @subviews
      subview.run()
    
  setup : ()->
    # override in child class
  
  addSubview : (subview)->
    unless subview.id of @subviews
      @subviews[subview.id] = subview
      subview.parent = @

  addSubviews : (subviews)->
    for view in subviews
      @addSubview(view)
  
  removeSubview : (subview)->
    if subview.id of @subviews
      delete @subviews[subview.id]
      subview.parent = null
      subview.removeBehaviors()
  
  removeSubviews : (subviews)->
    for view in subviews
      @removeSubview(view)

  removeAllSubviews : ()->
    for id, subview of @subviews
      @removeSubview(subview)

  setId : (id)->
    @id = id
  
  setContainer : ()->
    @$container = $("##{@id}")
  
  sync : (id_map)->        
    ids = Object.keys(id_map)
    temp_ids = Object.keys(@subviews)
    
    if (ids.length != temp_ids.length)
      throw "Mismatch between subview id lengths"
    
    for i in [0..(ids.length - 1)]
      id = ids[i]
      map = id_map[id]
      
      temp_id = temp_ids[i]
      view = @subviews[temp_id]
      
      if view
        view.setId(id)
        view.setContainer()
        view.sync(map)
  
  addBehaviors : ()->
    @addBehavior(@$container)
    
    attr = @behavior()
    behaviors = @$container.find("[#{attr}]")
    for node in behaviors
      $node = $(node)
      @addBehavior($node)
  
  addBehavior : ($node)->
    attr = @behavior()
    value = $node.attr(attr)
    unless value
      return

    [event_name, handler_name] = value.split(':')

    if handler_name of @
      event_name = @ns(event_name)
      handler = @[handler_name]
      $node.on(event_name, (event)->
        handler(
          event : event
          node  : this
          $node : $node
        )
      )

  removeBehaviors : ()->
    if @$container
      @$container.off()
      @$container.find("*").off()
    
  template : ()->
    '<h1>You should probably define .template on your view</h1>'
  
  html : ()->
    html = @template()
    @addViewId(html)

  refresh : (rerun = true)->
    @removeBehaviors()
    html = @html()
    @$container.replaceWith(html)
    if rerun
      @run()
    
  addViewId : (html)->
    html.replace(VIEW_REGEX, "$1 #{@idAttr()}")
  
      
module.exports = View