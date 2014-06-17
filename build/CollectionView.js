(function() {
  var CollectionView, Type, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Type = require('type-of-is');

  View = require('./View');

  CollectionView = (function(_super) {
    __extends(CollectionView, _super);

    CollectionView.prototype.collection_name = null;

    CollectionView.prototype.has_subviews = false;

    function CollectionView() {
      var ItemView, collection_name, item_data, model, view, _i, _len, _ref;
      CollectionView.__super__.constructor.apply(this, arguments);
      if (!this.item) {
        throw "CollectionView must define item View";
      }
      collection_name = this.collection_name || 'collection';
      if (collection_name in this.data) {
        this.collection = this.data[collection_name];
      }
      if (!this.collection) {
        throw "CollectionView must define collection or pass via constructor";
      }
      if (Type.extension(this.item, View)) {
        this.has_subviews = true;
        ItemView = this.item;
        _ref = this.collection;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          item_data = this.itemData();
          item_data.model = model;
          view = new ItemView(item_data);
          this.addSubview(view);
        }
      }
    }

    CollectionView.prototype.wrapper = function(html) {
      return html;
    };

    CollectionView.prototype.itemData = function() {
      return {
        collection_view: this
      };
    };

    CollectionView.prototype.template = function() {
      var html, id, model, subview, _i, _len, _ref, _ref1;
      html = '';
      if (this.has_subviews) {
        _ref = this.subviews;
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

    return CollectionView;

  })(View);

  module.exports = CollectionView;

}).call(this);
