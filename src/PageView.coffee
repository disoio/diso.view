$ = require('jquery')

View = require('./View')
Tag  = require('./Tag')

class PageView extends View
  @PAGE_DOM_ID : 'page'
  
  site_name   : "YR PAGE SHOULD HAVE A 'site_name'"
  description : "YR PAGE SHOULD HAVE A 'description'"
  keywords    : []
  scripts     : []
  styles      : []
  
  constructor : (options)->
    super()
    
    @route = options.route
    @url   = options.url
    @data  = options.data || {}
    
    @body = null
    if ('Body' of options)
      Body = options.Body
      body = new Body(@data)
      @setBody(body)
      
  setBody : (body)->
    if @body
      @removeSubview(@body)
    @body = body
    @addSubview(@body)
  
  swapBody : (new_body)->
    $body = $("##{@body.id}")
    $body.replaceWith(new_body.html())
    @setBody(new_body)
    new_body.setContainer()
    new_body.addBehaviors()
    new_body.run()
      
  idMap : ()->
    map = {}
    map[@id] = super()
    map
  
  @create : (options)->    
    id_map = options.id_map
    delete options.id_map
    
    page = new @(options)
    page_id = Object.keys(id_map)[0]
    page.setId(page_id)
    page.setContainer()
    
    map = id_map[page_id]
    page.sync(map)
    
    page
    
  meta : (data)->
    metadata = {
      name : {
        description : data.description || @description
        keywords    : @keywords
        viewport    : @viewport || 'width=device-width, initial-scale=1'
      }
      itemprop : {
        name        : data.title
        description : data.description
        image       : data.image
        url         : data.url
      }
      property : {
        "og:title"       : data.title
        "og:description" : data.description
        "og:image"       : data.image
        "og:type"        : data.type || 'website'
        "og:url"         : data.url
        "og:site_name"   : data.site_name || data.title
      }
    }
      
    html = ''
    for attr, m of metadata
      for name, content of m
        opts = { 
          content : content
        }
        opts[attr] = name
        html += Tag.meta(opts) + "\n"
      
    html
    
  template : ()->
    "YR PAGE NEEDS A TEMPLATE"
    
  container : ()->
    """
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          #{@meta(@body.meta())}

          <title>#{@body.meta().title || @site_name}</title>

          #{(Tag.stylesheet(href: href) for href in @styles).join("\n")}
          
          #{(Tag.script(src: src) for src in @scripts).join("\n")}
          
          #{@head()}          
        </head>
        
        <body data-page-type="#{@constructor.name}" data-body-type="#{@body.constructor.name}" #{@idAttr()}>
          #{@template()}
        </body>
      </html>
    """
    
  html : ()->
    html = @container()
    
module.exports = PageView