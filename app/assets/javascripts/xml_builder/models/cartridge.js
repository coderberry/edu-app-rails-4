App.Cartridge = Ember.Model.extend({
  data       : Ember.attr(),
  name       : Ember.attr(),
  created_at : Ember.attr(),
  updated_at : Ember.attr()

}).reopenClass({
  rootKey       : 'cartridge',
  collectionKey : 'cartridges',
  url           : '/api/v1/cartridges',
  adapter       : Ember.RESTAdapter.create()
});