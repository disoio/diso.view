(function() {
  var CollectionView, Type, View, throwError,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Type = require('type-of-is');

  View = require('./View');

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

    function CollectionView() {
      var collection_name;
      CollectionView.__super__.constructor.apply(this, arguments);
      collection_name = this._collectionName();
      if ('collection' in this.data) {
        this[collection_name] = this.data.collection;
      } else if (this.collection_name && (this.collection_name in this.data)) {
        this[collection_name] = this.data[this.collection_name];
      }
      if (!this.collection) {
        throwError("Missing collection");
      }
      if (!this.item) {
        throwError("Missing item template or view");
      }
      this._setupItemViews();
    }

    CollectionView.prototype.addModel = function(model) {
      var i, index, len, other_model, _i, _ref;
      if (!Type(model.isEqual, Function)) {
        throwError("collection model missing isEqual method");
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

    CollectionView.prototype.refresh = function(rerun) {
      if (rerun == null) {
        rerun = true;
      }
      this.removeAllSubviews();
      this.setupItemViews();
      return CollectionView.__super__.refresh.call(this, rerun);
    };

    CollectionView.prototype.wrapper = function(html) {
      return html;
    };

    CollectionView.prototype.itemData = function() {
      return {};
    };

    CollectionView.prototype.template = function() {
      var html, id, model, subview, _i, _len, _ref, _ref1;
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
          model = _ref1[_i];
          html += this.item(model);
        }
      }
      return this.wrapper(html);
    };

    CollectionView.prototype._setupItemViews = function() {
      var ItemView, item_data, model, view, _i, _len, _ref, _results;
      if (Type.extension(this.item, View)) {
        this.item_is_view = true;
        ItemView = this.item;
        _ref = this.collection;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          item_data = this.itemData();
          item_data.model = model;
          item_data.collection_view = this;
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
