require 'nokogiri'
require 'open-uri'

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
    params.stringify_keys!
    c = self.config
    tool = IMS::LTI::ToolConfig.new
    platform = 'canvas.instructure.com'

    cot = EA::ConfigOptionTool.new(c['config_options'], params)
    unless cot.is_valid?
      puts cot.errors.inspect
      raise EA::MissingConfigOptionsError.new("Missing required parameters", cot.errors)
    end

    tool.title       = cot.sub(c['title'])       if c['title'].present?
    tool.description = cot.sub(c['description']) if c['description'].present?
    tool.launch_url  = cot.sub(c['launch_url'])  if c['launch_url'].present?
    tool.icon        = cot.sub(c['icon_url'])    if c['icon_url'].present?

    tool.set_ext_param(platform, 'tool_id', c['tool_id'])                          if c['tool_id'].present?
    tool.set_ext_param(platform, 'privacy_level', c['privacy_level'])             if c['privacy_level'].present?
    tool.set_ext_param(platform, 'domain', cot.sub(c['domain']))                   if c['domain'].present?
    tool.set_ext_param(platform, 'link_text', cot.sub(c['text']))                  if c['text'].present?
    tool.set_ext_param(platform, 'selection_width', cot.sub(c['default_width']))   if c['default_width'].present?
    tool.set_ext_param(platform, 'selection_height', cot.sub(c['default_height'])) if c['default_height'].present?

    c['launch_types'].each do |name, ext|
      opts = {}
      ext.each do |key, value|
        opts[key] = cot.sub(ext[key]) if ext[key].present?
      end
      tool.set_ext_param(platform, name, opts)
    end

    #['editor_button', 'resource_selection', 'homework_submission'].each do |ext_name|
    #  if c['launch_types'][ext_name]
    #    ext = c['launch_types'][ext_name]
    #    opts = {}
    #    opts['enabled'] = ext['enabled']                  if ext['enabled'].present?
    #    opts['url'] = cot.sub(ext['url'])                 if ext['url'].present?
    #    opts['icon_url'] = cot.sub(ext['icon_url'])       if ext['icon_url'].present?
    #    opts['text'] = cot.sub(ext['text'])               if ext['text'].present?
    #    opts['selection_width'] = cot.sub(ext['selection_width'])   if ext['selection_width'].present?
    #    opts['selection_height'] = cot.sub(ext['selection_height']) if ext['selection_height'].present?
    #    tool.set_ext_param(platform, ext['name'], opts)
    #  end
    #end
    #
    #['course_navigation', 'account_navigation', 'user_navigation'].each do |ext_name|
    #  if c['launch_types'][ext_name]
    #    ext = c['launch_types'][ext_name]
    #    opts = {}
    #    opts['enabled'] = true
    #    opts['url'] = cot.sub(ext['url']) if ext['url'].present?
    #    opts['text'] = cot.sub(ext['text']) if ext['text'].present?
    #    if ext_name == 'course_navigation'
    #      opts['visibility'] = ext['visibility'] if ext['visibility'].present?
    #      #opts['default'] = ext['enabled_by_default'] ? 'enabled' : 'disabled'
    #    end
    #    tool.set_ext_param(platform, ext['name'], opts)
    #  end
    #end

    (c['custom_fields'] || []).each do |cf|
      tool.set_custom_param(cf['name'], cot.sub(cf['value']))
    end

    tool
  end

  # class methods .............................................................
  class << self
    def create_from_url(user_id, url)
      return nil if url.blank?
      begin
        xml = open(url).read
        create_from_xml(user_id, xml)
      rescue Errno::ENOENT => ex
        # Not a valid URL
        nil
      end
    end

    def create_from_xml(user_id, xml)
      begin
        cartridge = xml_to_cartridge(xml)
        create(user_id: user_id, config: cartridge.as_json)
      rescue => ex
        nil
      end
    end

    def xml_to_cartridge(xml)
      doc = Nokogiri::XML(xml.strip) do |config|
        config.strict.noblanks
      end
      cartridge = EA::Cartridge.new
      cartridge.title               = doc.root.xpath('//blti:title').text
      cartridge.description         = doc.root.xpath('//blti:description').text
      cartridge.icon_url            = doc.root.xpath('//blti:extensions/lticm:options/lticm:property[@name="icon_url"]').first.try(:text)
      cartridge.launch_url          = doc.root.xpath('//blti:launch_url').text
      cartridge.tool_id             = doc.root.xpath('//blti:extensions/lticm:property[@name="tool_id"]').text
      cartridge.text                = doc.root.xpath('//blti:extensions/lticm:property[@name="link_text"]').text
      cartridge.default_width       = doc.root.xpath('//blti:extensions/lticm:property[@name="selection_width"]').text
      cartridge.default_height      = doc.root.xpath('//blti:extensions/lticm:property[@name="selection_height"]').text
      cartridge.privacy_level      = doc.root.xpath('//blti:extensions/lticm:property[@name="privacy_level"]').text
      cartridge.domain              = doc.root.xpath('//blti:extensions/lticm:property[@name="domain"]').text
      cartridge.editor_button       = EA::ModalExtension.new(name: 'editor_button')
      cartridge.resource_selection  = EA::ModalExtension.new(name: 'resource_selection')
      cartridge.homework_submission = EA::ModalExtension.new(name: 'homework_submission')
      cartridge.course_navigation   = EA::NavigationExtension.new(name: 'course_navigation')
      cartridge.account_navigation  = EA::NavigationExtension.new(name: 'account_navigation')
      cartridge.user_navigation     = EA::NavigationExtension.new(name: 'user_navigation')

      # Custom Fields
      doc.xpath('//blti:custom/lticm:property').each do |node|
        cartridge.custom_fields << EA::CustomField.new( name: node['name'], value: node.text )
      end

      cartridge.editor_button.enabled               = (doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.editor_button.url                   = doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="url"]').text
      cartridge.editor_button.text                  = doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="text"]').text
      cartridge.editor_button.icon_url              = doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="icon_url"]').text
      cartridge.editor_button.selection_width       = doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="selection_width"]').text
      cartridge.editor_button.selection_height      = doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="selection_height"]').text

      cartridge.resource_selection.enabled          = (doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.resource_selection.url              = doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="url"]').text
      cartridge.resource_selection.text             = doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="text"]').text
      cartridge.resource_selection.icon_url         = doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="icon_url"]').text
      cartridge.resource_selection.selection_width  = doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="selection_width"]').text
      cartridge.resource_selection.selection_height = doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="selection_height"]').text

      cartridge.homework_submission.enabled         = (doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.homework_submission.url             = doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="url"]').text
      cartridge.homework_submission.text            = doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="text"]').text
      cartridge.homework_submission.icon_url        = doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="icon_url"]').text
      cartridge.homework_submission.selection_width = doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="selection_width"]').text
      cartridge.homework_submission.selection_height= doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="selection_height"]').text

      cartridge.course_navigation.enabled           = (doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.course_navigation.url               = doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="url"]').text
      cartridge.course_navigation.text              = doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="text"]').text
      cartridge.course_navigation.visibility        = doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="visibility"]').text
      cartridge.course_navigation.enabled_by_default= doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="default"]').text

      cartridge.account_navigation.enabled          = (doc.xpath('//blti:extensions/lticm:options[@name="account_nav"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.account_navigation.url              = doc.xpath('//blti:extensions/lticm:options[@name="account_nav"]/lticm:property[@name="url"]').text
      cartridge.account_navigation.text             = doc.xpath('//blti:extensions/lticm:options[@name="account_nav"]/lticm:property[@name="text"]').text

      cartridge.user_navigation.enabled             = (doc.xpath('//blti:extensions/lticm:options[@name="user_nav"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.user_navigation.url                 = doc.xpath('//blti:extensions/lticm:options[@name="user_nav"]/lticm:property[@name="url"]').text
      cartridge.user_navigation.text                = doc.xpath('//blti:extensions/lticm:options[@name="user_nav"]/lticm:property[@name="text"]').text

      cartridge
    end
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
