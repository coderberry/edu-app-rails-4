module EA
  class CanvasExtension
    include Hashable
    attr_accessor :name, :is_optional, :enabled

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}", value)
      end
      @is_optional ||= false
      @enabled  ||= true
    end
  end
end