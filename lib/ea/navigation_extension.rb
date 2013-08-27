module EA
  class NavigationExtension < CanvasExtension
    attr_accessor :name, :isEnabled, :isOptional, :launchUrl, :linkText, :visibility, :enabledByDefault

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @isEnabled  ||= false
      @isOptional ||= false
    end
  end
end