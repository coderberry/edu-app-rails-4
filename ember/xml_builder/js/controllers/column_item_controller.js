var ColumnItemController = Ember.ObjectController.extend({
  sortColumn: Ember.computed.alias('parentController.sortedColumn'),
  sortAscending: Ember.computed.alias('parentController.sortAscending'),
  sortDescending: Ember.computed.not('sortAscending'),
  
  isSorted: (function() {
    return this.get('sortColumn') === this.get('name');
  }).property('sortColumn', 'name'),
  
  sortedAsc: Ember.computed.and('sortAscending', 'isSorted'),
  sortedDesc: Ember.computed.and('sortDescending', 'isSorted')
});

module.exports = ColumnItemController;

