module EA
  class CanvasExtension
    include Hashable
    attr_accessor :name, :enabled

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}", value)
      end
      @enabled  ||= true
    end
  end
end