var Jsonable = Ember.Mixin.create({
  getJson: function() {
    var v, json = {};
    for (var key in this) {
      if (key === 'modifiedAt') { continue; }
      
      if (this.hasOwnProperty(key)) {
        v = this[key];
        if (v === 'toString') {
          continue;
        } 
        if (Ember.typeOf(v) === 'function') {
          continue;
        }
        if (App.Jsonable.detect(v))
          v = v.getJson();
        json[key] = v;
      }
    }
    return json;
  }
});

module.exports = Jsonable;
