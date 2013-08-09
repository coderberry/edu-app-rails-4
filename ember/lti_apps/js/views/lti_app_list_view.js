var LtiAppListView = Ember.CollectionView.extend({
  tagName: 'ol',
  templateName: 'lti_apps',
  classNames: ['clearfix'],
  elementId: 'lti-apps-container',
  itemViewClass: 'App.LtiAppView'
});

module.exports = LtiAppListView;
