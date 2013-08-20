var SyntaxHighlighterComponent = Ember.Component.extend({
  formattedCode: '',

  didInsertElement: function() {
    this.formatCode();
  },

  codeObserver: function() {
    this.formatCode();
  }.observes('code'),

  formatCode: function() {
    var brush = new SyntaxHighlighter.brushes.Xml()
    brush.init({ toolbar: false });
    var raw_code = this.get('code');
    if (!Ember.isEmpty(raw_code)) {
      this.set('formattedCode', new Handlebars.SafeString(brush.getHtml(raw_code)));
    }
  }
});

module.exports = SyntaxHighlighterComponent;

