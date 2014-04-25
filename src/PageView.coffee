View = require('./View')
Tag  = require('./Tag')

class PageView extends View
  @PAGE_DOM_ID : 'page'
  
  site_name : "YR PAGE SHOULD HAVE A 'site_name'"
  keywords  : []
  scripts   : []
  styles    : []
  
  constructor : (@data)->
    super
    
    @route = @data.route
    
    @body = null
    if 'body' of @data
      @body = @data.body
      @contains(@body)

  idMap : ()->
    map = {}
    map[@id] = super()
    map
  
  @create : (options)->
    Body   = options.Body
    data   = options.data
    id_map = options.id_map
    
    body = new Body(options.data)
    page = new @(body : body)
    
    page_id = Object.keys(id_map)[0]
    page.setId(page_id)
    map = id_map[page_id]
    page.sync(map)
    
    page
    
  meta : (data)->
    metadata = {
      name : {
        description : data.description
        keywords    : "#{@keywords.concat(data.keywords).join(', ')}"
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