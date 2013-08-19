var EmClipboardComponent = Ember.Component.extend({
  didInsertElement: function () {
    var clip = new ZeroClipboard(this.$('button'), {
      moviePath: '/assets/ZeroClipboard.swf'
    });
  }
});

module.exports = EmClipboardComponent;

