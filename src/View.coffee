$ = require('jquery')
Uuid = require('node-uuid')

regexForDomId = (dom_id)->
  regex_str = "(<[\\w\\s]*?id=\"#{dom_id}\"[^>]*)>"
  regex = new RegExp(regex_str, 'm')

class View
  @BEHAVIOR_ATTR = 'data-behavior'
  @VIEW_ID_ATTR = 'data-view-id'
  
  behavior : (value)->
    attr = "#{@constructor.BEHAVIOR_ATTR}-#{@id}"
    if value
      "#{attr}=\"#{value}\""
    else
      attr
  
  constructor : (@data)->
    @data ?= {}
    @id = Uuid.v4()
    @subviews = {}
    @container_dom_id = null
  
  run : ()->
    # override in child class
  
  contains : (options)->
    @subviews[options.view.id] = options
  
  contained : (options)->
    # this gets called in the process of syncing 
    # tell this view who its container is and overwrite its view id from the dom
    @container_dom_id = options.dom_id
    @$container = $("##{@container_dom_id}")
    @id = @$container.attr(@constructor.VIEW_ID_ATTR)
    
  sync : ()->
    @addBehaviors()
      
    for id, subview of @subviews
      view = subview.view
      view.contained(dom_id : subview.dom_id)
      view.sync()
    
    @run()
    
  ns : (event_name)->
    "#{event_name}.#{@id}"
  
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
    @populateSubviews(html)
    
  populateSubviews : (html)->
    # subview replacement with regex based on id so that substition can be made 
    # server side without dependency on a dom.
    # TODO: evaluate more robust approaches like using Virtual Dom from React as a component
    for id, subview of @subviews
      view = subview.view
      view_html = view.html()
      regex = regexForDomId(subview.dom_id)
      html = html.replace(regex, "$1 #{@constructor.VIEW_ID_ATTR}=\"#{id}\">#{view_html}")
    
    html
  
  json : ()->
    JSON.stringify(@data)
      
module.exports = View