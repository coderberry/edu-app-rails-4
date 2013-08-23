module EA
  class Cartridge
    include Hashable
    attr_accessor :title, :description, :icon_url, :launch_url, :extensions, :custom_fields, :config_options

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @extensions     ||= []
      @custom_fields  ||= []
      @config_options ||= []
    end

    def as_json
      self.as_hash.to_json
    end
  end
end