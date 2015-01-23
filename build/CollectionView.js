(function() {
  var CollectionView, ModelView, Type, View, throwError,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Type = require('type-of-is');

  View = require('./View');

  ModelView = require('./ModelView');

  throwError = function(msg) {
    throw new Error("diso.view.Collection: " + msg);
  };

  CollectionView = (function(_super) {
    __extends(CollectionView, _super);

    CollectionView.prototype.collection_name = null;

    CollectionView.prototype._collectionName = function() {
      return this.collection_name || '_collection';
    };

    CollectionView.prototype.item_is_view = false;

    function CollectionView(args) {
      var collection, collection_in_args, collection_name;
      if (args == null) {
        args = {};
      }
      if (args.data == null) {
        args.data = {};
      }
      collection = null;
      collection_in_args = 'collection' in args;
      if (collection_in_args) {
        collection = args.collection;
        delete args.collection;
      } else if (this.collection_name && (this.collection_name in args.data)) {
        if (collection_in_args) {
          throwError("Can't pass collection arg and named collection in data");
        }
        collection = args.data[this.collection_name];
      }
      if (this.collection && !collection) {
        collection = this.collection;
      }
      if (!collection) {
        throwError("Missing collection in " + this.constructor.name);
      }
      if (!this.item) {
        throwError("Missing item template or view");
      }
      CollectionView.__super__.constructor.call(this, args);
      collection_name = this._collectionName();
      this[collection_name] = collection;
      this._setupItemViews();
      if (this.sort) {
        if (!Type(this.sort, Function)) {
          throwError("sort attribute is not a function");
        }
        this[collection_name] = this[collection_name].sort(this.sort);
      }
    }

    CollectionView.prototype.addModel = function(model) {
      var i, index, len, other_model, _i, _ref;
      if (!Type(model.isEqual, Function)) {
        throwError("Collection model missing isEqual method");
      }
      index = null;
      len = this.collection.length;
      if (len > 0) {
        for (i = _i = 0, _ref = len - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          other_model = this.collection[i];
          if (model.isEqual(other_model)) {
            index = i;
            break;
          }
        }
      }
      if (index) {
        return this.collection[index] = model;
      } else {
        return this.collection.unshift(model);
      }
    };

    CollectionView.prototype.refresh = function(resetup) {
      if (resetup == null) {
        resetup = true;
      }
      this.removeAllSubviews();
      this._setupItemViews();
      return CollectionView.__super__.refresh.call(this, resetup);
    };

    CollectionView.prototype.wrapper = function(contents) {
      return "<div>\n  " + contents + "\n</div>";
    };

    CollectionView.prototype.itemData = function() {
      return {};
    };

    CollectionView.prototype.sort = null;

    CollectionView.prototype.template = function() {
      var html, id, item, subview, _i, _len, _ref, _ref1;
      html = '';
      if (this.item_is_view) {
        _ref = this.subviews();
        for (id in _ref) {
          subview = _ref[id];
          html += subview.html();
        }
      } else {
        _ref1 = this.collection;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          item = _ref1[_i];
          html += this.item(item);
        }
      }
      return this.wrapper(html);
    };

    CollectionView.prototype._setupItemViews = function() {
      var ItemView, item, item_data, k, v, view, _i, _len, _ref, _results;
      if (Type.extension(this.item, View)) {
        this.item_is_view = true;
        ItemView = this.item;
        _ref = this.collection;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          item_data = {
            user: this.user,
            data: this.itemData()
          };
          if (Type.extension(ItemView, ModelView)) {
            item_data.model = item;
          } else {
            for (k in item) {
              v = item[k];
              item_data.data[k] = v;
            }
          }
          view = new ItemView(item_data);
          _results.push(this.addSubview(view));
        }
        return _results;
      }
    };

    return CollectionView;

  })(View);

  Object.defineProperty(CollectionView.prototype, 'collection', {
    get: function() {
      return this[this._collectionName()];
    },
    set: function(val) {
      return this[this._collectionName()] = val;
    }
  });

  module.exports = CollectionView;

}).call(this);
