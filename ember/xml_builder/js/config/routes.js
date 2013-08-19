var App = require('./app');

App.Router.map(function() {
  this.resource('cartridges', { path: '/' }, function() {
    this.resource('cartridge', { path: '/:uid' });
  });
});

