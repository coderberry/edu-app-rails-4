var BootstrapDropdownSelectComponent = Ember.Component.extend({
  noneLabel: 'All',
  tagName: 'li',
  classNames: ['dropdown'],

  opts: function() {
    var ret = Em.ArrayProxy.create({content:[]});
    if (!Ember.isEmpty(this.get('options'))) {
      Em.$.each(this.get('options'), function (idx, opt) {
        ret.pushObject(Ember.Object.create({ id: opt.id.toString(), name: opt.name }));
      });
    }
    return ret;
  }.property('options'),
  
  selectedOption: function() {
    var opt = this.get('opts').findProperty('id', this.get('value'));
    if (opt) {
      return opt.get('name');
    } else {
      return this.get('noneLabel');
    }
  }.property('opts', 'value', 'noneLabel'),
  
  actions: {
    select: function(opt) {
      this.set('value', opt.get('id'));
    },

    clear: function() {
      this.set('value', null);
    }
  }
});

module.exports = BootstrapDropdownSelectComponent;

