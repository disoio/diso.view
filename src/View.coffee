$ = require('jquery')
Uuid = require('node-uuid')
Type = require('type-of-is')

VIEW_REGEX = (()->
  regex_str = "^(\\s*<[\\w][\\w0-9]*)"
  new RegExp(regex_str, 'm')
)()

class View
  @BEHAVIOR_ATTR  = 'data-behavior'
  @ID_ATTR_NAME   = 'id'
  
  constructor : (@data)->
    @data ?= {}
    @id = Uuid.v4()
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
    # override in child class
  
  contains : (views)->
    unless Type(views, Array)
      views = [views]
      
    for view in views
      @subviews[view.id] = view

  setId : (id)->
    @id = id
    @$container = $("##{@id}")
  
  sync : (id_map)->    
    @addBehaviors()
    
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
        view.sync(map)
    
    @run()
  
  addBehaviors : ()->
    attr = @behavior()
    behaviors = @$container.find("[#{attr}]")
    for node in behaviors
      $node = $(node)
      @addBehavior($node)
  
  addBehavior : ($node)->
    attr = @behavior()
    value = $node.attr(attr)
    [event_name, handler_name] = value.split(':')

    if handler_name of @
      event_name = @ns(event_name)
      handler = @[handler_name]
      $node.on(event_name, handler)
    
  template : ()->
    '<h1>You should probably define .template on your view</h1>'
  
  html : ()->
    html = @template()
    @addViewId(html)
    
  addViewId : (html)->
    html.replace(VIEW_REGEX, "$1 #{@idAttr()}")
  
  json : ()->
    JSON.stringify(@data)
      
module.exports = View