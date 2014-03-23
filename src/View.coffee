class View
  constructor : (@data)->
    
  template : ()->
    '<h1>You should probably define .template on your view</h1>'
  
  html : ()->
    @template()
  
  json : ()->
    JSON.stringify(@data)
      
module.exports = View