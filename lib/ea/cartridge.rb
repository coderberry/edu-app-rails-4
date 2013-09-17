module EA
  class Cartridge
    include Hashable
    attr_accessor :title, :description, :icon_url, :launch_url, :tool_id, :text, :default_width,
                  :default_height, :privacy_level, :domain, :editor_button, :resource_selection,
                  :homework_submission, :course_navigation, :account_navigation, :user_navigation,
                  :optional_launch_types
    attr_accessor :custom_fields, :config_options

    def initialize(attrs={})
      attrs.each do |key,value|
        instance_variable_set("@#{key}",value)
      end
      @custom_fields ||= []
      @config_options ||= []
      @launch_types ||= []
      @optional_launch_types ||= []
    end

    def launch_types
      lt = {}
      lt['editor_button'] = @editor_button.as_hash if @editor_button
      lt['resource_selection'] = @resource_selection.as_hash if @resource_selection
      lt['homework_submission'] = @homework_submission.as_hash if @homework_submission
      lt['course_navigation'] = @course_navigation.as_hash if @course_navigation
      lt['account_navigation'] = @account_navigation.as_hash if @account_navigation
      lt['user_navigation'] = @user_navigation.as_hash if @user_navigation
      lt
    end

    def as_json
      JSON.parse({
        title: @title,
        description: @description,
        icon_url: @icon_url,
        launch_url: @launch_url,
        tool_id: @tool_id,
        text: @text,
        default_width: @default_width,
        default_height: @default_height,
        privacy_level: @privacy_level,
        domain: @domain,
        custom_fields: @custom_fields,
        config_options: @config_options,
        optional_launch_types: @optional_launch_types,
        launch_types: self.launch_types
      }.to_json)
    end
  end
end