(function() {
  var ModelView, View, throwError,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  View = require('./View');

  throwError = function(msg) {
    throw new Error("diso.view.Model: " + msg);
  };

  ModelView = (function(_super) {
    __extends(ModelView, _super);

    ModelView.prototype.model_name = null;

    ModelView.prototype._modelName = function() {
      return this.model_name || '_model';
    };

    function ModelView(args) {
      var model, model_in_args, model_name;
      if (!args.data) {
        args.data = {};
      }
      model = null;
      model_in_args = 'model' in args;
      if (model_in_args) {
        model = args.model;
        delete args.model;
      }
      if (this.model_name && (this.model_name in args.data)) {
        if (model_in_args) {
          throwError("Can't pass model arg and named model in data");
        }
        model = args.data[this.model_name];
      }
      if (!model) {
        throwError("Missing model in " + this.constructor.name);
      }
      ModelView.__super__.constructor.call(this, args);
      model_name = this._modelName();
      this[model_name] = model;
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
