module EA
  class NavigationExtension < CanvasExtension
    attr_accessor :name, :enabled, :is_optional, :url, :text, :visibility, :enabled_by_default

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @enabled  ||= false
      @is_optional ||= false
    end
  end
end