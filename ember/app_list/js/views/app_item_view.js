var AppItemView = Ember.View.extend({
  classNames: ['app-item', 'col-3'],
  layoutName: '_app_item',

  didInsertElement: function() {
    console.log("Inserted item");
  },

  eventManager: Ember.Object.create({
    mouseEnter: function(event, view) {
      view.$().children(0).addClass('border-shadow');
    },
    mouseLeave: function(event, view) {
      view.$().children(0).removeClass('border-shadow');
    }
  })
});

module.exports = AppItemView;
