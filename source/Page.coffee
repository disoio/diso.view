# NPM dependencies
# ------------------
# [jquery](https://github.com/jquery/jquery)  
# [type-of-is](https://github.com/stephenhandley/type-of-is)  
$    = require('jquery')
Type = require('type-of-is')

# Local dependencies
# ------------------
# [View](./View.html)  
View = require('./View')

# Page
# ====
# A page is a view that is at the root of a view hierarchy
# and it is responsible for loading the data needed to render
# it's child views, adding them as subviews as providing them 
# process through which to subscribe to and fetch data from 
# a datastore
class Page extends View
  scripts  : []
  styles   : []
  viewport : null
  _loaded  : false
  _headers : {}
  _body    : null

  # Child classes override this. Can be function or object
  # If function will be called and should return an object
  meta : {
    title       : null
    description : null
    image       : null
    type        : null
  }

  # constructor
  # -----------
  # Create a page
  #
  # ### required args
  # **store**  : the store for this page
  #
  # **route**  : the route for this page
  #
  # **origin** : the origin where this page is served from 
  #             i.e. https://blah.example.com
  #
  # ### optional args
  # **container** : the container for this page. this isn't
  #                 used on the server, but should be present
  #                 in the client in order to provide access 
  #                 to goto and other container methods
  #
  # **data**      : In general, the page will be fetching its 
  #                 own data via its store. The one exception
  #                 is when the data is already available (for
  #                 example, during the initialize process in 
  #                 diso.core the data was available during the
  #                 serverside render and so can be sent along
  #                 with the view id_map and so is set via this
  #                 constructor arg)
  constructor : (args)->
    super(args.data || {})
    @store     = args.store
    @route     = args.route
    @url       = "#{args.origin}#{@route.path()}"
    @container = args.container

  # setData
  # -------
  # Set the data for this page.
  setData : (data)->
    @data = data

  # setMeta 
  # -------
  # Call with object to set those properties on @meta. 
  # when called with no arguments (i.e. by the container) it 
  # returns underlying @meta object
  setMeta : (metadata)->
    if metadata
      unless Type(metadata, Object)
        throw new Error("Argument to meta should be object")
      
      for k,v of metadata
        @meta[k] = v
    else
      @meta

  # getMeta
  # -------
  # Get the underlying meta object which can be a plain object
  # or a function. If its a function, call it to return plain
  # object
  getMeta : ()->
    if Type(@meta, Function)
      @meta()
    else
      @meta

  # title
  # -----
  # Returns the title for this page
  title : ()->
    meta = @getMeta()
    meta.title

  # setBody
  # -------
  # set the body of this page
  setBody : (new_body)->
    if @_body
      @removeSubview(@_body)
    @_body = new_body
    @addSubview(@_body)
  
  # swapBody 
  # --------
  # Change the body of this page to a different view
  swapBody : (new_body)->
    $body = @_body.$node()
    @setBody(new_body)
    $body.replaceWith(new_body.html())
    new_body.run()

  # remove
  # ------
  # Remove the page and all its views
  remove : ()->
    @_body.removeAllSubviews()
    @removeSubview(@_body)
    @_body     = null
    @store     = null
    @route     = null
    @url       = null
    @container = null


  # *TODODODODO*
  # ------------
  showModal : ()->
  hideModal : ()->

  # *STUB METHODS*
  # --------------
  # These methods should/may be implemented by child classes 

  # load
  # ----
  # Child classes should override this to load the data from 
  # the @store. After retrieving the data they should
  load : (callback)->
    # @store.get(...)
    callback(null, null)
  
  # build
  # -----
  # Child classes should override this to construct and add the
  # views for the page
  build : ()->

  # template
  # --------
  # Child classes should override this method to provide 
  # any wrapper html needed around this page's body view
  template : ()->
    if @_body
      @_body.html()
    else
      ''

  # headers
  # -------
  # Child classes can optionally override to specify or set
  # any HTTP headers specific to this view
  headers : ()->
    @_headers

  # head
  # ----
  # Child classes may override this to provide a string
  # of html that will be inserted into the page's <head> section
  head : ()->
    ''

module.exports = Page