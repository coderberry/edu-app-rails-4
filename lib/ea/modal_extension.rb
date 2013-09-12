module EA
  class ModalExtension < CanvasExtension
    attr_accessor :name, :enabled, :url, :text, :icon_url, :selection_width, :selection_height

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @enabled  ||= false
    end
  end
end