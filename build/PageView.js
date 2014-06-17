(function() {
  var $, PageView, Tag, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  $ = require('jquery');

  View = require('./View');

  Tag = require('./Tag');

  PageView = (function(_super) {
    __extends(PageView, _super);

    PageView.PAGE_DOM_ID = 'page';

    PageView.prototype.site_name = "YR PAGE SHOULD HAVE A 'site_name'";

    PageView.prototype.description = "YR PAGE SHOULD HAVE A 'description'";

    PageView.prototype.keywords = [];

    PageView.prototype.scripts = [];

    PageView.prototype.styles = [];

    function PageView(options) {
      var Body, body;
      PageView.__super__.constructor.call(this);
      this.route = options.route;
      this.url = options.url;
      this.data = options.data || {};
      this.body = null;
      if ('Body' in options) {
        Body = options.Body;
        body = new Body(this.data);
        this.setBody(body);
      }
    }

    PageView.prototype.setBody = function(body) {
      if (this.body) {
        this.removeSubview(this.body);
      }
      this.body = body;
      return this.addSubview(this.body);
    };

    PageView.prototype.swapBody = function(new_body) {
      var $body;
      $body = $("#" + this.body.id);
      $body.replaceWith(new_body.html());
      this.setBody(new_body);
      new_body.setContainer();
      return new_body.run();
    };

    PageView.prototype.idMap = function() {
      var map;
      map = {};
      map[this.id] = PageView.__super__.idMap.call(this);
      return map;
    };

    PageView.create = function(options) {
      var id_map, map, page, page_id;
      id_map = options.id_map;
      delete options.id_map;
      page = new this(options);
      page_id = Object.keys(id_map)[0];
      page.setId(page_id);
      page.setContainer();
      map = id_map[page_id];
      page.sync(map);
      page.run();
      return page;
    };

    PageView.prototype.meta = function(data) {
      var attr, content, html, m, metadata, name, opts;
      metadata = {
        name: {
          description: data.description || this.description,
          keywords: this.keywords,
          viewport: this.viewport || 'width=device-width, initial-scale=1'
        },
        itemprop: {
          name: data.title,
          description: data.description,
          image: data.image,
          url: data.url
        },
        property: {
          "og:title": data.title,
          "og:description": data.description,
          "og:image": data.image,
          "og:type": data.type || 'website',
          "og:url": data.url,
          "og:site_name": data.site_name || data.title
        }
      };
      html = '';
      for (attr in metadata) {
        m = metadata[attr];
        for (name in m) {
          content = m[name];
          opts = {
            content: content
          };
          opts[attr] = name;
          html += Tag.meta(opts) + "\n";
        }
      }
      return html;
    };

    PageView.prototype.template = function() {
      return "YR PAGE NEEDS A TEMPLATE";
    };

    PageView.prototype.head = function() {
      return '';
    };

    PageView.prototype.container = function() {
      var href, src;
      return "<!DOCTYPE html>\n<html>\n  <head>\n    <meta charset=\"utf-8\">\n    " + (this.meta(this.body.meta())) + "\n\n    <title>" + (this.body.meta().title || this.site_name) + "</title>\n\n    " + (((function() {
        var _i, _len, _ref, _results;
        _ref = this.styles;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          href = _ref[_i];
          _results.push(Tag.stylesheet({
            href: href
          }));
        }
        return _results;
      }).call(this)).join("\n")) + "\n    \n    " + (((function() {
        var _i, _len, _ref, _results;
        _ref = this.scripts;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          src = _ref[_i];
          _results.push(Tag.script({
            src: src
          }));
        }
        return _results;
      }).call(this)).join("\n")) + "\n    \n    " + (this.head()) + "          \n  </head>\n  \n  <body data-page-type=\"" + this.constructor.name + "\" data-body-type=\"" + this.body.constructor.name + "\" " + (this.idAttr()) + ">\n    " + (this.template()) + "\n  </body>\n</html>";
    };

    PageView.prototype.html = function() {
      var html;
      return html = this.container();
    };

    return PageView;

  })(View);

  module.exports = PageView;

}).call(this);
