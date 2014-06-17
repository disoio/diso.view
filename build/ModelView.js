(function() {
  var ModelView, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  View = require('./View');

  ModelView = (function(_super) {
    __extends(ModelView, _super);

    ModelView.prototype.model_name = 'model';

    function ModelView() {
      ModelView.__super__.constructor.apply(this, arguments);
      this[this.model_name] = this.data.model;
    }

    ModelView.prototype.model = function() {
      return this[this.model_name];
    };

    return ModelView;

  })(View);

  module.exports = ModelView;

}).call(this);
