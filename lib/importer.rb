class Importer
  def initialize
    @json = JSON.parse(File.read("#{Rails.root}/data/dump.json"))
  end

  def run
    self.wipeout
    self.import_tags
    self.import_organizations

    user = User.where(twitter_nickname: "whitmer").first

    @json['apps'].each do |data|
      configuration = self.import_lti_app_configuration(user, data)
      puts "CONFIG: #{configuration.id}"
      unless configuration.new_record?
        app = self.import_lti_app(user, configuration, data)
        puts "APP: #{app.id}"
      end
    end
  end

  def wipeout
    Tag.destroy_all
    Organization.destroy_all
    User.destroy_all
    LtiAppConfiguration.destroy_all
    LtiApp.destroy_all
    Review.destroy_all
  end

  def import_tags
    data = JSON.parse(File.read("#{Rails.root}/data/seed_data.json"))
    data['tags'].each do |tag|
      Tag.create(name: tag["name"], short_name: tag["short_name"], context: tag["context"])
    end
  end

  def import_organizations
    @json["external_access_token"].each do |node|
      organization = Organization.where(name: node["name"]).first_or_create( url: node["site_url"] )
      organization.api_keys.where(access_token: node["token"]).first_or_create

      @json["permissions"].each do |perm|
        if perm["organization_id"] == node["id"]
          user = User.where(twitter_nickname: perm["username"][1..-1]).first_or_create({
            name: perm["username"][1..-1],
            is_omniauthing: true
          })
          membership = Membership.where(organization_id: organization.id, user_id: user.id).first_or_create({
            is_admin: true
          })
        end
      end
    end

    @json["permissions"].each do |perm|
      if perm["organization_id"].blank?
        # Create an organization
        organization = Organization.where( name: "ORG: #{perm['username'][1..-1]}" ).first_or_create
        user = User.where(twitter_nickname: perm["username"][1..-1]).first_or_create({
          name: perm["username"][1..-1],
          is_omniauthing: true
        })
        membership = Membership.where(organization_id: organization.id, user_id: user.id).first_or_create({
          is_admin: true
        })
      end
    end
  end

  def import_lti_app_configuration(user, data)
    lti_app_configuration = LtiAppConfiguration.new(user_id: user.id, short_name: data['id'])

    cartridge = EA::Cartridge.new
    cartridge.title       = data['name']
    cartridge.description = data['short_description'].present? ? data['short_description'] : data['description']
    cartridge.icon_url    = edu_appify_link(data['icon_url'].is_a?(Array) ? data['icon_url'].first : data['icon_url'])
    cartridge.launch_url  = edu_appify_link(data['open_launch_url'] || data['launch_url'])

    # Custom Fields
    data['custom_fields'].each do |k, v|
      cartridge.custom_fields << EA::CustomField.new( name: k, value: v )
    end if data['custom_fields'].present?

    canvas_extension = EA::Extension.new
    canvas_extension.platform                 = 'canvas.instructure.com'
    canvas_extension.tool_id                  = data['id']
    canvas_extension.privacy_level            = data['privacy_level']
    canvas_extension.domain                   = data['domain']
    canvas_extension.default_link_text        = data['course_nav_link_text'] || data['user_nav_link_text'] || data['account_nav_link_text']
    canvas_extension.default_selection_width  = data['width'].to_i if data['width'].present?
    canvas_extension.default_selection_height = data['height'].to_i if data['height'].present?

    optional_extensions = []

    # Config Options
    data['config_options'].each do |opt|
      name = opt['name']
      if ['editor_button', 'resource_selection', 'homework_submission', 'course_nav', 'account_nav', 'user_nav'].include? name
        optional_extensions << name
      else
        cartridge.config_options << EA::ConfigOption.new( name:          name, 
                                                          default_value: opt['value'], 
                                                          is_required:   opt['required'], 
                                                          description:   opt['description'], 
                                                          type:          opt['type'] )
      end
    end if data['config_options'].present?

    # Canvas Extensions
    data['extensions'].each do |extension|
      if ['editor_button', 'resource_selection', 'homework_submission'].include? extension
        canvas_extension.options << EA::ModalExtension.new( name: extension, is_optional: (optional_extensions.include? extension) )
      elsif ['course_nav', 'account_nav', 'user_nav'].include? extension
        canvas_extension.options << EA::NavigationExtension.new( name: extension, is_optional: (optional_extensions.include? extension) )
      end
    end if data['extensions'].present?

    cartridge.extensions << canvas_extension

    lti_app_configuration.config = cartridge.as_json
    unless lti_app_configuration.save
      puts lti_app_configuration.errors.inspect
    end

    return lti_app_configuration
  end

  def import_lti_app(user, configuration, data)
    app = LtiApp.new(lti_app_configuration_id: configuration.id)
    app.user_id                  = 1 # hardcoded for now
    app.name                     = data['name']
    app.status                   = data['pending'] == true ? 'pending' : 'active'
    app.short_name               = data['id']
    app.short_description        = data['short_description']
    app.description              = data['description']
    app.testing_instructions     = data['test_instructions']
    app.author_name              = data['author_name']
    app.app_type                 = data['app_type']
    app.support_url              = data['support_link']
    app.ims_cert_url             = data['ims_link']
    app.config_url               = edu_appify_link(data['config_url'])
    app.preview_url              = edu_appify_link(data['preview'] ? data['preview']['url'] : nil)
    app.banner_image_url         = edu_appify_link(data['banner_url'])
    app.logo_image_url           = edu_appify_link(data['logo_url'])
    
    if app.save
      @map = maps
      if data['categories'].is_a? Array
        data['categories'].each do |val|
          puts "CAT: #{val}"
          app.tags << @map[:categories][val]
        end
      end

      if data['levels'].is_a? Array
        data['levels'].each do |val|
          puts "LVL: #{val}"
          app.tags << @map[:education_levels][val]
        end
      end

      if data['beta'] == true
        app.tags << @map[:categories]['Beta']
      end

    else
      puts "ERROR: #{data['name']} - #{app.errors.full_messages.inspect}"
    end

    return app
  end

  def maps
    category_map = {}
    Tag.categories.each do |t|
      category_map[t.name] = t
    end

    education_level_map = {}
    Tag.education_levels.each do |t|
      education_level_map[t.name] = t
    end

    return {
      categories: category_map,
      education_levels: education_level_map
    }
  end

  def edu_appify_link(url)
    if url.present? && url =~ /^\//
      "http://www.edu-apps.org#{url}"
    else
      url
    end
  end
end