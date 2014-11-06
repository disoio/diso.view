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

# LoadingView
# ===========
# Placeholder loading view. Pages can overide this with 
# via 'loading_view' attribute on child class of Page
class LoadingView extends View
  id : 'loading'

  template : ()->
    """
    <div>
      <div class="loading_message">
        Loading...
      </div>
    </div>
    """

# Page
# ====
# A page is a view that is at the root of a view hierarchy
# and it is responsible for loading the data needed to render
# it's child views, adding them as subviews as providing them 
# process through which to subscribe to and fetch data from 
# models
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

  requires_user : false

  loading_view : LoadingView

  is_page : true

  # constructor
  # -----------
  # Create a page
  #
  # ### required args
  #
  # **models** : models used by this page
  #
  # **route**  : the route for this page
  #
  # **origin** : the origin where this page is served from 
  #             i.e. https://blah.example.com
  #
  # **user** : Object representing current user
  # 
  constructor : (args)->
    super()
    @models = args.models
    @route  = args.route
    @url    = "#{args.origin}#{@route.path()}"
    @_user  = args.user

  # setData
  # -------
  # Set the data for this page.
  setData : (data)->
    @page_data = data

  # hasUser
  # -------
  # Returns true if user is not null
  hasUser : ()->
    !!@_user

  # needsUser
  # ---------
  # Returns true if this page needs a user and so can
  # not render until the user is there
  needsUser : ()->
    (@requires_user and (not @hasUser()))

  # key
  # ---
  # Key used for identifying a page
  key : ()->
    "#{@constructor.name}:#{@id}"

  # setMeta 
  # -------
  # Call with object to set those properties on @meta. 
  # when called with no arguments (i.e. by the container) it 
  # returns underlying @meta object
  setMeta : (metadata)->
    if metadata
      unless Type(metadata, Object)
        throw new Error("diso.view.Page: Argument to meta should be object")
      
      for k,v of metadata
        @meta[k] = v
    else
      @meta

  setBodyToLoadingView : ()->
    LoadingView = @loading_view
    loading_view = new LoadingView()
    @setBody(loading_view)

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

  # buildAndSetBody
  # ---------------
  buildAndSetBody : ()->
    body = @build()
    if body
      unless Type.instance(body, View)
        throw new Error("diso.view.Page: build should return View for body")
      @setBody(body)
  
  # swapBody 
  # --------
  # Change the body of this page to a different view
  swapBody : (new_body)->
    $body = @_body.$node()
    html  = new_body.html()
    $body.replaceWith(html)
    @setBody(new_body)
    new_body.setup()

  # replaceLoadingBody
  # ------------------
  replaceLoadingWithBuild : ()->
    $body = @_body.$node()
    @buildAndSetBody()
    html = @_body.html()
    $body.replaceWith(html)

  # remove
  # ------
  # Remove the page and all its views
  remove : ()->
    @_body.removeAllSubviews()
    @removeSubview(@_body)
    @_body     = null
    @route     = null
    @url       = null

  # *TODODODODO*
  # ------------
  showModal : ()->
  hideModal : ()->

  # *STUB METHODS*
  # --------------
  # These methods should/may be implemented by child classes 

  # load
  # ----
  # Child classes should override this to load the data
  # from models. After retrieving the data they should
  # call callback with (error, data)
  load : (callback)->
    callback(null, null)
  
  # build
  # -----
  # Child classes should override this to construct and add the
  # views for the page
  build : ()->
    null

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