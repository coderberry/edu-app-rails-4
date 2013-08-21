require 'nokogiri'
require 'open-uri'

class Cartridge < ActiveRecord::Base
  # relationships .............................................................
  belongs_to :user
  has_one :lti_app

  # callbacks .................................................................
  before_create :generate_uid

  # validations ...............................................................
  validates :user_id, presence: true
  validates :name, presence: true
  validates :xml, presence: true
  validate  :validate_lti_launch_url

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
        create(
          name: doc.xpath('//blti:title').first.text,
          xml:  doc.to_html
        )
      rescue => ex
        nil
      end
    end
  end

  # public instance methods ..................................................
  def tool_config
    IMS::LTI::ToolConfig.create_from_xml(self.xml)
  end

  def to_xml
    self.xml
  end

  def parsed_xml
    Nokogiri::XML(self.xml)
  end

  def extensions
    ext = {}
    self.parsed_xml.xpath('//blti:extensions/lticm:options').each do |e|
      attributes = e.attributes
      name = attributes.delete('name').value
      ext[name] = {}
      attributes.each do |k,v|
        ext[name][k] = v.to_s
      end
    end
    ext
  end

  def custom_params
    params = {}
    self.parsed_xml.xpath('//blti:custom/lticm:property').each do |e|
      attributes = e.attributes
      name = attributes.delete('name').value
      params[name] = {}
      attributes.each do |k,v|
        params[name][k] = v.to_s
      end
    end
    params
  end

  # private instance methods ..................................................
  private

  def validate_lti_launch_url
    lti_launch_url = self.tool_config.try(:launch_url)
    if !lti_launch_url.present?
      errors.add(:lti_launch_url, "must be a valid URL")
    end
  end

  def generate_uid
    begin
      len = 16
      self.uid = rand(36**len).to_s(36)
    end while self.class.exists?(uid: uid)
  end
end
