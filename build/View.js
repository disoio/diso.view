(function() {
  var $, BEHAVIOR_ATTR, ID_ATTR_NAME, ShortId, Type, VIEW_REGEX, View;

  $ = require('jquery');

  ShortId = require('shortid');

  Type = require('type-of-is');

  VIEW_REGEX = (function() {
    var regex_str;
    regex_str = "^(\\s*<[\\w][\\w0-9]*)";
    return new RegExp(regex_str, 'm');
  })();

  BEHAVIOR_ATTR = 'data-behavior';

  ID_ATTR_NAME = 'id';

  View = (function() {
    View.prototype.id = null;

    function View(data) {
      this.data = data;
      if (this.data == null) {
        this.data = {};
      }
      if (!this.id) {
        this.id = ShortId.generate();
      }
      this._subviews = {};
    }

    View.prototype.html = function() {
      var html;
      html = this.template();
      return this._addViewId(html);
    };

    View.prototype.refresh = function(rerun) {
      var html;
      if (rerun == null) {
        rerun = true;
      }
      this._removeBehaviors();
      html = this.html();
      this.$node.replaceWith(html);
      if (rerun) {
        return this.run();
      }
    };

    View.prototype.behavior = function(value) {
      return "" + (this._behaviorAttr()) + "=\"" + value + "\"";
    };

    View.prototype.run = function() {
      var id, subview, _ref, _results;
      this.setup();
      this._addBehaviors();
      _ref = this._subviews;
      _results = [];
      for (id in _ref) {
        subview = _ref[id];
        _results.push(subview.run());
      }
      return _results;
    };

    View.prototype.page = function() {
      var view;
      if (!this._page) {
        view = this;
        while (view.parent) {
          view = view.parent;
        }
        this._page = view;
      }
      return this._page;
    };

    View.prototype.goto = function(args) {
      return this.page().container.goto(args);
    };

    View.prototype.setNode = function(id) {
      this.id = id;
      return this.$node = $("#" + this.id);
    };

    View.prototype.subviews = function() {
      return this._subviews;
    };

    View.prototype.addSubview = function(subview) {
      if (!(subview.id in this._subviews)) {
        this._subviews[subview.id] = subview;
        return subview.parent = this;
      }
    };

    View.prototype.addSubviews = function(subviews) {
      var view, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = subviews.length; _i < _len; _i++) {
        view = subviews[_i];
        _results.push(this.addSubview(view));
      }
      return _results;
    };

    View.prototype.removeSubview = function(subview) {
      if (subview.id in this._subviews) {
        delete this._subviews[subview.id];
        subview.parent = null;
        return subview.removeBehaviors();
      }
    };

    View.prototype.removeSubviews = function(subviews) {
      var view, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = subviews.length; _i < _len; _i++) {
        view = subviews[_i];
        _results.push(this.removeSubview(view));
      }
      return _results;
    };

    View.prototype.removeAllSubviews = function() {
      var id, subview, _ref, _results;
      _ref = this._subviews;
      _results = [];
      for (id in _ref) {
        subview = _ref[id];
        _results.push(this.removeSubview(subview));
      }
      return _results;
    };

    View.prototype.setup = function() {};

    View.prototype.template = function() {
      return "<h1>\n  You need to add a <strong>template</strong> method to your view\n</h1>";
    };

    View.prototype._addBehaviors = function() {
      var $node, attr, behaviors, node, _i, _len, _results;
      this._addBehavior(this.$node);
      attr = this._behaviorAttr();
      behaviors = this.$node.find("[" + attr + "]");
      _results = [];
      for (_i = 0, _len = behaviors.length; _i < _len; _i++) {
        node = behaviors[_i];
        $node = $(node);
        _results.push(this._addBehavior($node));
      }
      return _results;
    };

    View.prototype._addBehavior = function($node) {
      var attr, event_name, handler, handler_name, value, _ref;
      attr = this._behaviorAttr();
      value = $node.attr(attr);
      if (!value) {
        return;
      }
      _ref = value.split(':'), event_name = _ref[0], handler_name = _ref[1];
      if (handler_name in this) {
        event_name = this._namespaceEvent(event_name);
        handler = this[handler_name];
        return $node.on(event_name, function(event) {
          return handler({
            event: event,
            node: this,
            $node: $node
          });
        });
      } else {
        return console.error("no event handler on view named " + handler_name);
      }
    };

    View.prototype._removeBehaviors = function() {
      if (this.$node) {
        this.$node.off();
        return this.$node.find("*").off();
      }
    };

    View.prototype._addViewId = function(html) {
      return html.replace(VIEW_REGEX, "$1 " + (this._idAttr()));
    };

    View.prototype._behaviorAttr = function() {
      return "" + BEHAVIOR_ATTR + "-" + this.id;
    };

    View.prototype._idAttr = function() {
      return "" + ID_ATTR_NAME + "=\"" + this.id + "\"";
    };

    View.prototype._namespaceEvent = function(event_name) {
      return "" + event_name + "." + this.id;
    };

    return View;

  })();

  module.exports = View;

}).call(this);
