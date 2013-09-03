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

    cot = EA::ConfigOptionTool.new(c['configOptions'], params)
    unless cot.is_valid?
      puts cot.errors.inspect
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

    (c['customFields'] || []).each do |cf|
      tool.set_custom_param(cf['name'], cot.sub(cf['value']))
    end

    tool
  end

  # class methods .............................................................
  class << self
    def create_from_url(url)
      return nil if url.blank?
      begin
        xml = open(url).read
        create_from_xml(xml)
      rescue Errno::ENOENT => ex
        # Not a valid URL
        nil
      end
    end

    def create_from_xml(xml)
      begin
        doc = Nokogiri::XML(xml.strip) do |config|
          config.strict.noblanks
        end
        cartridge = xml_to_cartridge(xml)
        create(config: cartridge.as_json)
      rescue => ex
        nil
      end
    end

    def xml_to_cartridge(xml)
      doc = Nokogiri::XML(xml)
      cartridge = EA::Cartridge.new
      cartridge.title              = doc.root.xpath('//blti:title').text
      cartridge.description        = doc.root.xpath('//blti:description').text
      cartridge.iconUrl            = doc.root.xpath('//blti:extensions/lticm:options/lticm:property[@name="icon_url"]').first.text
      cartridge.launchUrl          = doc.root.xpath('//blti:launch_url').text
      cartridge.toolId             = doc.root.xpath('//blti:extensions/lticm:property[@name="tool_id"]').text
      cartridge.defaultLinkText    = doc.root.xpath('//blti:extensions/lticm:property[@name="link_text"]').text
      cartridge.defaultWidth       = doc.root.xpath('//blti:extensions/lticm:property[@name="selection_width"]').text
      cartridge.defaultHeight      = doc.root.xpath('//blti:extensions/lticm:property[@name="selection_height"]').text
      cartridge.launchPrivacy      = doc.root.xpath('//blti:extensions/lticm:property[@name="privacy_level"]').text
      cartridge.domain             = doc.root.xpath('//blti:extensions/lticm:property[@name="domain"]').text
      cartridge.editorButton       = EA::ModalExtension.new(name: 'editor_button')
      cartridge.resourceSelection  = EA::ModalExtension.new(name: 'resource_selection')
      cartridge.homeworkSubmission = EA::ModalExtension.new(name: 'homework_submission')
      cartridge.courseNav          = EA::NavigationExtension.new(name: 'course_nav')
      cartridge.accountNav         = EA::NavigationExtension.new(name: 'account_nav')
      cartridge.userNav            = EA::NavigationExtension.new(name: 'user_nav')

      # Custom Fields
      doc.xpath('//blti:custom/lticm:property').each do |node|
        cartridge.customFields << EA::CustomField.new( name: node['name'], value: node.text )
      end

      optional_extensions = []

      cartridge.editorButton.isEnabled        = (doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.editorButton.launchUrl        =  doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="url"]').text
      cartridge.editorButton.linkText         =  doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="text"]').text
      cartridge.editorButton.iconUrl          =  doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="icon_url"]').text
      cartridge.editorButton.width            =  doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="selection_width"]').text
      cartridge.editorButton.height           =  doc.xpath('//blti:extensions/lticm:options[@name="editor_button"]/lticm:property[@name="selection_height"]').text

      cartridge.resourceSelection.isEnabled   = (doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.resourceSelection.launchUrl   =  doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="url"]').text
      cartridge.resourceSelection.linkText    =  doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="text"]').text
      cartridge.resourceSelection.iconUrl     =  doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="icon_url"]').text
      cartridge.resourceSelection.width       =  doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="selection_width"]').text
      cartridge.resourceSelection.height      =  doc.xpath('//blti:extensions/lticm:options[@name="resource_selection"]/lticm:property[@name="selection_height"]').text

      cartridge.homeworkSubmission.isEnabled  = (doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.homeworkSubmission.launchUrl  =  doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="url"]').text
      cartridge.homeworkSubmission.linkText   =  doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="text"]').text
      cartridge.homeworkSubmission.iconUrl    =  doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="icon_url"]').text
      cartridge.homeworkSubmission.width      =  doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="selection_width"]').text
      cartridge.homeworkSubmission.height     =  doc.xpath('//blti:extensions/lticm:options[@name="homework_submission"]/lticm:property[@name="selection_height"]').text

      cartridge.courseNav.isEnabled           = (doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.courseNav.launchUrl           =  doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="url"]').text
      cartridge.courseNav.linkText            =  doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="text"]').text
      cartridge.courseNav.visibility          =  doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="visibility"]').text
      cartridge.courseNav.enabledByDefault    =  doc.xpath('//blti:extensions/lticm:options[@name="course_nav"]/lticm:property[@name="default"]').text

      cartridge.accountNav.isEnabled          = (doc.xpath('//blti:extensions/lticm:options[@name="account_nav"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.accountNav.launchUrl          =  doc.xpath('//blti:extensions/lticm:options[@name="account_nav"]/lticm:property[@name="url"]').text
      cartridge.accountNav.linkText           =  doc.xpath('//blti:extensions/lticm:options[@name="account_nav"]/lticm:property[@name="text"]').text

      cartridge.userNav.isEnabled             = (doc.xpath('//blti:extensions/lticm:options[@name="user_nav"]/lticm:property[@name="enabled"]').text == 'true')
      cartridge.userNav.launchUrl             =  doc.xpath('//blti:extensions/lticm:options[@name="user_nav"]/lticm:property[@name="url"]').text
      cartridge.userNav.linkText              =  doc.xpath('//blti:extensions/lticm:options[@name="user_nav"]/lticm:property[@name="text"]').text

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
