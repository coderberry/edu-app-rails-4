// App.Cartridge = Ember.Model.extend({
//   cartridge  : Ember.attr(),

// }).reopenClass({
//   rootKey       : 'cartridge',
//   collectionKey : 'cartridges',
//   url           : '/api/v1/cartridges',
//   adapter       : Ember.Adapter.create({
//     createRecord: function() {
      
//     },
    
//     save: function() {
//       Ember.$.post({
//         url: '/api/v1/cartridges',
//         data: JSON.stringify(this.get('cartridge')),
//         success: function( data ) {
//           alert(data);
//         }
//       })
//     }
//   })
// });