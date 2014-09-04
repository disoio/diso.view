(function() {
  var CollectionView, ModelView, Page, View;

  View = require('./View');

  CollectionView = require('./CollectionView');

  Page = require('./Page');

  ModelView = require('./ModelView');

  View.Collection = CollectionView;

  View.Page = Page;

  View.Model = ModelView;

  module.exports = View;

}).call(this);
