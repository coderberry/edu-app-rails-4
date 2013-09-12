module EA
  class NavigationExtension < CanvasExtension
    attr_accessor :name, :enabled, :url, :text, :visibility, :enabled_by_default

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @enabled  ||= false
    end
  end
end