var AppListView = Ember.CollectionView.extend({
  elementId:       'apps-container',
  itemViewClass:   'App.AppItemView',
  
  didInsertElement: function() {
    console.log("Inserted container");
  },

  onChildViewsChanged : function( obj, key ){
    var length = this.get( 'childViews.length' );
    if( length > 0 ){
      Ember.run.scheduleOnce( 'afterRender', this, 'childViewsDidRender' );
    }
  }.observes( 'childViews' ),

  childViewsDidRender : function(){
    console.log("child views have finished rendering!");
  }
});

module.exports = AppListView;

