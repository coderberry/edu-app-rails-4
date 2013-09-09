module EA
  class ModalExtension < CanvasExtension
    attr_accessor :name, :is_enabled, :is_optional, :launch_url, :link_text, :icon_url, :width, :height

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @is_enabled  ||= false
      @is_optional ||= false
    end
  end
end