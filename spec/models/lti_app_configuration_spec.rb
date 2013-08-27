require 'spec_helper'

describe LtiAppConfiguration do
  describe "#tool_config" do
    before :each do
      @lti_app_configuration = LtiAppConfiguration.create(
        user_id: 1,
        config: {
          "extensions" => [
            {
              "options" => [
                {
                  "name" => "editor_button",
                  "is_optional" => false,
                  "is_enabled" => true
                },
                { 
                  "name" => "resource_selection",
                  "is_optional" => false,
                  "is_enabled" => true
                }
              ], 
              "platform" => "canvas.instructure.com",
              "tool_id" => "twitter",
              "privacy_level" => "anonymous",
              "domain" => nil,
              "default_link_text" => nil,
              "default_selection_width" => 690,
              "default_selection_height" => 530
            }
          ], 
          "custom_fields" => [],
          "config_options" => [],
          "title" => "Twitter",
          "description" => "Embed tweet streams",
          "icon_url" => "http://www.edu-apps.org/tools/twitter/icon.png",
          "launch_url" => "http://www.edu-apps.org/tools/public_collections/index.html?tool=twitter"
        }
      )
    end

    it "should convert to a valid cartridge" do
      @lti_app_configuration.uid.should =~ /\S{15}/
      tool = @lti_app_configuration.tool_config
      puts tool.launch_url
      puts tool.icon
      puts tool.to_xml
    end
  end
end
