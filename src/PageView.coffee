View = require('./View')
Tag  = require('./Tag')

class PageView extends View
  constructor : (data)->
    @body  = data.body
    @route = data.route

  keywords  : []
  site_name : "YR PAGE SHOULD HAVE A 'site_name'"
  scripts   : []
  styles    : []
  
  meta : (data)->     
    data = {
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
    for attr, m of data
      for name, content of m
        opts = { 
          content : content
        }
        opts[attr] = name
        html += Tag.meta(opts) + "\n"
      
    html
    
  template : ()->
    "YR PAGE SHOULD HAVE A TEMPLATE"
    
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
        
        <body>
          #{@template()}
        </body>
      </html>
    """
    
  html : ()->
    @container()
    
module.exports = PageView