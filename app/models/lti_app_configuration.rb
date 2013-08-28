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
  def launch_url;  self.config['launchUrl'];   end
  def icon_url;    self.config['iconUrl'];     end

  def tool_config(params={})
    c = self.config
    tool = IMS::LTI::ToolConfig.new
    platform = 'canvas.instructure.com'

    cot = EA::ConfigOptionTool.new(c['configOptions'], params)
    unless cot.is_valid?
      raise EA::MissingConfigOptionsError.new("Missing required parameters", cot.errors)
    end

    tool.title       = cot.sub(c['title'])       if c['title'].present?
    tool.description = cot.sub(c['description']) if c['description'].present?
    tool.launch_url  = cot.sub(c['launchUrl'])   if c['launchUrl'].present?
    tool.icon        = cot.sub(c['iconUrl'])     if c['iconUrl'].present?

    tool.set_ext_param(platform, 'tool_id', c['toolId'])                          if c['toolId'].present?
    tool.set_ext_param(platform, 'privacy_level', c['launchPrivacy'])             if c['launchPrivacy'].present?
    tool.set_ext_param(platform, 'domain', cot.sub(c['domain']))                  if c['domain'].present?
    tool.set_ext_param(platform, 'link_text', cot.sub(c['defaultLinkText']))      if c['defaultLinkText'].present?
    tool.set_ext_param(platform, 'selection_width', cot.sub(c['defaultWidth']))   if c['defaultWidth'].present?
    tool.set_ext_param(platform, 'selection_height', cot.sub(c['defaultHeight'])) if c['defaultHeight'].present?

    ['editorButton', 'resourceSelection', 'homeworkSubmission'].each do |ext_name|
      if c[ext_name] && c[ext_name]['isEnabled']
        ext = c[ext_name]
        opts = {}
        opts['enabled'] = true
        opts['url'] = cot.sub(ext['url'])                 if ext['url'].present?
        opts['icon_url'] = cot.sub(ext['iconUrl'])        if ext['iconUrl'].present?
        opts['text'] = cot.sub(ext['linkText'])           if ext['linkText'].present?
        opts['selection_width'] = cot.sub(ext['width'])   if ext['width'].present?
        opts['selection_height'] = cot.sub(ext['height']) if ext['height'].present?
        tool.set_ext_param(platform, ext['name'], opts)
      end
    end

    ['courseNav', 'accountNav', 'userNav'].each do |ext_name|
      if c[ext_name] && c[ext_name]['isEnabled']
        ext = c[ext_name]
        opts = {}
        opts['enabled'] = true
        opts['url'] = cot.sub(ext['launchUrl']) if ext['launchUrl'].present?
        opts['text'] = cot.sub(ext['linkText']) if ext['linkText'].present?
        if ext_name == 'course_nav'
          opts['visibility'] = ext['visibility'] if ext['visibility'].present?
          opts['default'] = ext['enabledByDefault'] ? 'enabled' : 'disabled'
        end
        tool.set_ext_param(platform, ext['name'], opts)
      end
    end

    c['customFields'].each do |cf|
      tool.set_custom_param(cf['name'], cot.sub(cf['value']))
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
