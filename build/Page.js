(function() {
  var $, LoadingView, Page, Type, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $ = require('jquery');

  Type = require('type-of-is');

  View = require('./View');

  LoadingView = (function(_super) {
    __extends(LoadingView, _super);

    function LoadingView() {
      return LoadingView.__super__.constructor.apply(this, arguments);
    }

    LoadingView.prototype.id = 'loading';

    LoadingView.prototype.template = function() {
      return "<div>\n  <div class=\"loading_message\">\n    Loading...\n  </div>\n</div>";
    };

    return LoadingView;

  })(View);

  Page = (function(_super) {
    __extends(Page, _super);

    Page.prototype.scripts = [];

    Page.prototype.styles = [];

    Page.prototype.viewport = null;

    Page.prototype._loaded = false;

    Page.prototype._headers = {};

    Page.prototype._body = null;

    Page.prototype.meta = {
      title: null,
      description: null,
      image: null,
      type: null
    };

    Page.prototype.requires_user = false;

    Page.prototype.loading_view = LoadingView;

    Page.prototype.is_page = true;

    function Page(args) {
      Page.__super__.constructor.call(this);
      this.models = args.models;
      this.route = args.route;
      this.url = "" + args.origin + (this.route.path());
      this._user = args.user;
    }

    Page.prototype.setData = function(data) {
      return this.page_data = data;
    };

    Page.prototype.hasUser = function() {
      return !!this._user;
    };

    Page.prototype.needsUser = function() {
      return this.requires_user && (!this.hasUser());
    };

    Page.prototype.key = function() {
      return "" + this.constructor.name + ":" + this.id;
    };

    Page.prototype.setMeta = function(metadata) {
      var k, v, _results;
      if (metadata) {
        if (!Type(metadata, Object)) {
          throw new Error("diso.view.Page: Argument to meta should be object");
        }
        _results = [];
        for (k in metadata) {
          v = metadata[k];
          _results.push(this.meta[k] = v);
        }
        return _results;
      } else {
        return this.meta;
      }
    };

    Page.prototype.setBodyToLoadingView = function() {
      var loading_view;
      LoadingView = this.loading_view;
      loading_view = new LoadingView();
      return this.setBody(loading_view);
    };

    Page.prototype.getMeta = function() {
      if (Type(this.meta, Function)) {
        return this.meta();
      } else {
        return this.meta;
      }
    };

    Page.prototype.title = function() {
      var meta;
      meta = this.getMeta();
      return meta.title;
    };

    Page.prototype.setBody = function(new_body) {
      if (this._body) {
        this.removeSubview(this._body);
      }
      this._body = new_body;
      return this.addSubview(this._body);
    };

    Page.prototype.buildAndSetBody = function() {
      var body;
      body = this.build(this.page_data);
      if (body) {
        if (!Type.instance(body, View)) {
          throw new Error("diso.view.Page: build should return View for body");
        }
        return this.setBody(body);
      }
    };

    Page.prototype.swapBody = function(new_body) {
      var $body, html;
      $body = this._body.$node();
      html = new_body.html();
      $body.replaceWith(html);
      this.setBody(new_body);
      return new_body.setup();
    };

    Page.prototype.replaceLoadingWithBuild = function() {
      var $body, html;
      $body = this._body.$node();
      this.buildAndSetBody();
      html = this._body.html();
      return $body.replaceWith(html);
    };

    Page.prototype.remove = function() {
      this._body.removeAllSubviews();
      this.removeSubview(this._body);
      this._body = null;
      this.route = null;
      return this.url = null;
    };

    Page.prototype.routeName = function() {
      return this.route.name;
    };

    Page.prototype.routeIs = function(route_name) {
      return this.routeName() === route_name;
    };

    Page.prototype.showModal = function() {};

    Page.prototype.hideModal = function() {};

    Page.prototype.load = function(callback) {
      return callback(null, null);
    };

    Page.prototype.build = function(data) {
      return null;
    };

    Page.prototype.error = function(error) {
      return console.error(error);
    };

    Page.prototype.html = function() {
      var body_html;
      body_html = this._body.html();
      return this.template(body_html);
    };

    Page.prototype.template = function(body) {
      return body;
    };

    Page.prototype.headers = function() {
      return this._headers;
    };

    Page.prototype.head = function() {
      return '';
    };

    return Page;

  })(View);

  module.exports = Page;

}).call(this);
