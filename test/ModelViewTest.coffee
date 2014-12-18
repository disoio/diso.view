Type       = require('type-of-is')
Assert     = require('assert')
Asserts    = require('asserts')
HtmlParser = require('htmlparser')

# stub ClientModel for testing interactions
class ClientModel 
  constructor : (data)->
    @setData(data)

  setData : (data)->
    for k,v of data
      @[k] = v


View = require('../source')

parseHtml = (args)->
  {html, callback} = args  
  handler = new HtmlParser.DefaultHandler(callback)
  parser = new HtmlParser.Parser(handler)
  parser.parseComplete(html)  

class Derp extends ClientModel

class DerpView extends View.Model
  model_name : 'derp'

  template : ()->
    "<div>#{@derp.name}</div>"

class DorpView extends View.Collection
  id   : "dorp"
  item : DerpView

  collection_name : 'dorp'

  wrapper : (contents)->
    """<div class="huh">#{contents}</div>"""

dorp_data = {
  dorp : [
    new Derp(
      i    : 1000
      name : 'duh'
    )
    new Derp(
      i    : 2000
      name : 'foo'
    )
  ]
}

module.exports = {
  "Within collection" : (done)->
    dorp_view = new DorpView(
      data : dorp_data
    )

    html = dorp_view.html()
    parseHtml(
      html     : html
      callback : (error, dom)->
        dom = dom[0]
        Assert.equal(dom.attribs.id, 'dorp')
        Assert.equal(dom.attribs.class, 'huh')

        for i in [0...dom.children.length]
          child = dom.children[i]
          name  = dorp_data.dorp[i].name
          Assert.equal(child.children[0].raw, name)
        done()
    )

  "model graph reference integrity" : (done)->
    dorp_view = new DorpView(
      data : dorp_data
    )

    first_derp = dorp_data.dorp[0]

    first_derp_view = null
    for k,v of dorp_view.subviews()
      if (v.derp.i is 1000)
        first_derp_view = v

    Assert.equal(first_derp, first_derp_view.derp)

    first_derp.setData({
      i    : 1000
      name : 'duhmmm'
    })

    Assert.equal(first_derp, first_derp_view.derp)
    done()
}