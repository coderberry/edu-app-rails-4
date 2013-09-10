module EA
  class Cartridge
    include Hashable
    attr_accessor :title, :description, :icon_url, :launch_url, :tool_id, :text, :default_width,
                  :default_height, :privacy_level, :domain, :editor_button, :resource_selection,
                  :homework_submission, :course_navigation, :account_navigation, :user_navigation
    attr_accessor :custom_fields, :config_options

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @custom_fields  ||= []
      @config_options ||= []
    end

    def as_json
      self.as_hash.to_json
    end
  end
end