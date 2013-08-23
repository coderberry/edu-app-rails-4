module EA
  class CanvasExtension
    include Hashable
    attr_accessor :name, :is_optional, :is_enabled

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}", value)
      end
      @is_optional ||= false
      @is_enabled  ||= true
    end
  end
end