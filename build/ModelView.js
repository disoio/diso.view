(function() {
  var ModelView, View,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  View = require('./View');

  ModelView = (function(_super) {
    __extends(ModelView, _super);

    ModelView.prototype.model_name = null;

    ModelView.prototype._modelName = function() {
      return this.model_name || '_model';
    };

    function ModelView() {
      var model_name;
      ModelView.__super__.constructor.apply(this, arguments);
      model_name = this._modelName();
      if ('model' in this.data) {
        this[model_name] = this.data.model;
      } else if (this.model_name && (this.model_name in this.data)) {
        this[model_name] = this.data[this.model_name];
      }
      if (!this.model) {
        throw new Error("diso.view.Model: Missing model: " + this.constructor.name);
      }
    }

    return ModelView;

  })(View);

  Object.defineProperty(ModelView.prototype, 'model', {
    get: function() {
      return this[this._modelName()];
    },
    set: function(val) {
      return this[this._modelName()] = val;
    }
  });

  module.exports = ModelView;

}).call(this);
