(function() {
  var $, BEHAVIOR_ATTR, BEHAVIOR_DELIMITER, BEHAVIOR_SEPARATOR, ID_ATTR_NAME, ShortId, Type, VIEW_REGEX, View;

  $ = require('jquery');

  ShortId = require('shortid');

  Type = require('type-of-is');

  VIEW_REGEX = (function() {
    var regex_str;
    regex_str = "^(\\s*<[\\w][\\w0-9]*)";
    return new RegExp(regex_str, 'm');
  })();

  ID_ATTR_NAME = 'id';

  BEHAVIOR_ATTR = 'data-behavior';

  BEHAVIOR_DELIMITER = ',';

  BEHAVIOR_SEPARATOR = ':';

  View = (function() {
    View.prototype.id = null;

    View.prototype._$node = null;

    View.prototype._page = null;

    View.prototype.is_page = false;

    function View(args) {
      if (!args) {
        args = {};
      }
      this.data = args.data || {};
      this._user = args.user;
      if ('id' in args) {
        this.id = args.id;
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
      this.removing();
      this._removeBehaviors();
      html = this.html();
      this.$node().replaceWith(html);
      this._$node = null;
      if (rerun) {
        return this.run();
      }
    };

    View.prototype.behavior = function(values) {
      if (!Type(values, Array)) {
        values = [values];
      }
      return "" + (this._behaviorAttr()) + "=\"" + (values.join(BEHAVIOR_DELIMITER)) + "\"";
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
        if (view.is_page) {
          this._page = view;
        }
      }
      return this._page;
    };

    View.prototype.setId = function(id) {
      this.id = id;
      return this._$node = null;
    };

    View.prototype.$node = function() {
      if (!this._$node) {
        this._$node = $("#" + this.id);
      }
      return this._$node;
    };

    View.prototype.remove = function() {
      if (this.parent) {
        this.parent.removeSubview(this);
      } else {
        this.removing();
      }
      return this.$node().remove();
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
        subview.removing();
        delete this._subviews[subview.id];
        subview.parent = null;
        subview._$node = null;
        subview._page = null;
        return subview._removeBehaviors();
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
        subview.removeAllSubviews();
        _results.push(this.removeSubview(subview));
      }
      return _results;
    };

    View.prototype.setup = function() {};

    View.prototype.template = function() {
      return "<h1>\n  You need to add a <strong>template</strong> method to your view\n</h1>";
    };

    View.prototype.removing = function() {};

    View.prototype._addBehaviors = function() {
      var $node, attr, behaviors, node, _i, _len, _results;
      this._addBehavior(this.$node());
      attr = this._behaviorAttr();
      behaviors = this.$node().find("[" + attr + "]");
      _results = [];
      for (_i = 0, _len = behaviors.length; _i < _len; _i++) {
        node = behaviors[_i];
        $node = $(node);
        _results.push(this._addBehavior($node));
      }
      return _results;
    };

    View.prototype._addBehavior = function($node) {
      var attr, value, values, _i, _len, _results;
      attr = this._behaviorAttr();
      values = $node.attr(attr);
      if (!values) {
        return;
      }
      values = values.split(BEHAVIOR_DELIMITER);
      _results = [];
      for (_i = 0, _len = values.length; _i < _len; _i++) {
        value = values[_i];
        _results.push((function(_this) {
          return function(value) {
            var event_name, handler, handler_name, _ref;
            _ref = value.split(BEHAVIOR_SEPARATOR), event_name = _ref[0], handler_name = _ref[1];
            if (handler_name in _this) {
              event_name = _this._namespaceEvent(event_name);
              handler = _this[handler_name];
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
        })(this)(value));
      }
      return _results;
    };

    View.prototype._removeBehaviors = function() {
      if (this.$node()) {
        return this.$node().off().find("*").off();
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

  Object.defineProperty(View.prototype, 'user', {
    get: function() {
      return this._user;
    },
    set: function(user) {
      return this._user = user;
    }
  });

  module.exports = View;

}).call(this);
