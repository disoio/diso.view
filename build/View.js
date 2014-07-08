(function() {
  var $, ShortId, Type, VIEW_REGEX, View;

  $ = require('jquery');

  ShortId = require('shortid');

  Type = require('type-of-is');

  VIEW_REGEX = (function() {
    var regex_str;
    regex_str = "^(\\s*<[\\w][\\w0-9]*)";
    return new RegExp(regex_str, 'm');
  })();

  View = (function() {
    View.BEHAVIOR_ATTR = 'data-behavior';

    View.ID_ATTR_NAME = 'id';

    function View(data) {
      this.data = data;
      if (this.data == null) {
        this.data = {};
      }
      if (!this.id) {
        this.id = ShortId.generate();
      }
      this.subviews = {};
    }

    View.prototype.idMap = function() {
      var id, map, subview, _ref;
      map = {};
      _ref = this.subviews;
      for (id in _ref) {
        subview = _ref[id];
        map[id] = subview.idMap();
      }
      return map;
    };

    View.prototype.behavior = function(value) {
      var attr;
      attr = "" + this.constructor.BEHAVIOR_ATTR + "-" + this.id;
      if (value) {
        return "" + attr + "=\"" + value + "\"";
      } else {
        return attr;
      }
    };

    View.prototype.ns = function(event_name) {
      return "" + event_name + "." + this.id;
    };

    View.prototype.idAttr = function() {
      return "" + this.constructor.ID_ATTR_NAME + "=\"" + this.id + "\"";
    };

    View.prototype.run = function() {
      var id, subview, _ref, _results;
      this.setContainer();
      this.setup();
      this.addBehaviors();
      _ref = this.subviews;
      _results = [];
      for (id in _ref) {
        subview = _ref[id];
        _results.push(subview.run());
      }
      return _results;
    };

    View.prototype.setup = function() {};

    View.prototype.addSubview = function(subview) {
      if (!(subview.id in this.subviews)) {
        this.subviews[subview.id] = subview;
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
      if (subview.id in this.subviews) {
        delete this.subviews[subview.id];
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
      _ref = this.subviews;
      _results = [];
      for (id in _ref) {
        subview = _ref[id];
        _results.push(this.removeSubview(subview));
      }
      return _results;
    };

    View.prototype.setId = function(id) {
      return this.id = id;
    };

    View.prototype.setContainer = function() {
      return this.$container = $("#" + this.id);
    };

    View.prototype.sync = function(id_map) {
      var i, id, ids, map, temp_id, temp_ids, view, _i, _ref, _results;
      ids = Object.keys(id_map);
      temp_ids = Object.keys(this.subviews);
      if (ids.length !== temp_ids.length) {
        throw "Mismatch between subview id lengths";
      }
      _results = [];
      for (i = _i = 0, _ref = ids.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        id = ids[i];
        map = id_map[id];
        temp_id = temp_ids[i];
        view = this.subviews[temp_id];
        if (view) {
          view.setId(id);
          view.setContainer();
          _results.push(view.sync(map));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    View.prototype.addBehaviors = function() {
      var $node, attr, behaviors, node, _i, _len, _results;
      this.addBehavior(this.$container);
      attr = this.behavior();
      behaviors = this.$container.find("[" + attr + "]");
      _results = [];
      for (_i = 0, _len = behaviors.length; _i < _len; _i++) {
        node = behaviors[_i];
        $node = $(node);
        _results.push(this.addBehavior($node));
      }
      return _results;
    };

    View.prototype.addBehavior = function($node) {
      var attr, event_name, handler, handler_name, value, _ref;
      attr = this.behavior();
      value = $node.attr(attr);
      if (!value) {
        return;
      }
      _ref = value.split(':'), event_name = _ref[0], handler_name = _ref[1];
      if (handler_name in this) {
        event_name = this.ns(event_name);
        handler = this[handler_name];
        return $node.on(event_name, function(event) {
          return handler({
            event: event,
            node: this,
            $node: $node
          });
        });
      }
    };

    View.prototype.removeBehaviors = function() {
      if (this.$container) {
        this.$container.off();
        return this.$container.find("*").off();
      }
    };

    View.prototype.template = function() {
      return '<h1>You should probably define .template on your view</h1>';
    };

    View.prototype.html = function() {
      var html;
      html = this.template();
      return this.addViewId(html);
    };

    View.prototype.refresh = function(rerun) {
      var html;
      if (rerun == null) {
        rerun = true;
      }
      this.removeBehaviors();
      html = this.html();
      this.$container.replaceWith(html);
      if (rerun) {
        return this.run();
      }
    };

    View.prototype.addViewId = function(html) {
      return html.replace(VIEW_REGEX, "$1 " + (this.idAttr()));
    };

    return View;

  })();

  module.exports = View;

}).call(this);
