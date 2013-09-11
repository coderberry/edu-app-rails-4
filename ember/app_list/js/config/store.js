DS.RESTAdapter.reopen({
  namespace: 'api/v1'
});

module.exports = DS.Store.extend({
  adapter: DS.RESTAdapter.create()
});

