class LtiAppConfiguration < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :user
  has_one :lti_app

  # callbacks .................................................................
  before_create :generate_uid

  # validations ...............................................................
  validates :user_id, presence: true

  # public instance methods ...................................................
  def title;       self.config['title'];       end
  def description; self.config['description']; end
  def launch_url;  self.config['launch_url'];  end
  def icon_url;    self.config['icon_url'];    end

  def tool_config
    tool = IMS::LTI::ToolConfig.new
    tool.title = self.title
    tool.description = self.description
    tool.launch_url = self.launch_url
    tool.icon = self.icon_url

    self.config['extensions'].each do |ext|
      platform = ext['platform']

      tool.set_ext_param(platform, 'tool_id', ext['tool_id'])                           if ext['tool_id'].present?
      tool.set_ext_param(platform, 'privacy_level', ext['privacy_level'])               if ext['privacy_level'].present?
      tool.set_ext_param(platform, 'domain', ext['domain'])                             if ext['domain'].present?
      tool.set_ext_param(platform, 'link_text', ext['default_link_text'])               if ext['default_link_text'].present?
      tool.set_ext_param(platform, 'selection_width', ext['default_selection_width'])   if ext['default_selection_width'].present?
      tool.set_ext_param(platform, 'selection_height', ext['default_selection_height']) if ext['default_selection_height'].present?

    end

    tool
  end

  # private instance methods ..................................................
  private

  def generate_uid
    begin
      len = 16
      self.uid = rand(36**len).to_s(36)
    end while self.class.exists?(uid: uid)
  end
end
