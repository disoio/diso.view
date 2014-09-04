(function() {
  var $, Page, Type, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $ = require('jquery');

  Type = require('type-of-is');

  View = require('./View');

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

    function Page(args) {
      Page.__super__.constructor.call(this, args.data || {});
      this.store = args.store;
      this.route = args.route;
      this.url = "" + args.origin + (this.route.path());
      this.container = args.container;
    }

    Page.prototype.setData = function(data) {
      return this.data = data;
    };

    Page.prototype.html = function() {
      return this.template();
    };

    Page.prototype.setMeta = function(metadata) {
      var k, v, _results;
      if (metadata) {
        if (!Type(metadata, Object)) {
          throw new Error("Argument to meta should be object");
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

    Page.prototype.title = function() {
      var meta;
      meta = this.meta;
      if (Type(meta, Function)) {
        meta = meta();
      }
      return meta.title;
    };

    Page.prototype.setBody = function(body) {
      if (this._body) {
        this.removeSubview(this._body);
      }
      this._body = body;
      return this.addSubview(this._body);
    };

    Page.prototype.swapBody = function(new_body) {
      var $body;
      $body = this._body.$node;
      $body.replaceWith(new_body.html());
      this.setBody(new_body);
      return new_body.run();
    };

    Page.prototype.showModal = function() {};

    Page.prototype.hideModal = function() {};

    Page.prototype.load = function(callback) {
      return callback(null, null);
    };

    Page.prototype.build = function() {};

    Page.prototype.template = function() {
      if (this._body) {
        return this._body.html();
      } else {
        return '';
      }
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
