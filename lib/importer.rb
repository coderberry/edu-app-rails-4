class Importer
  def initialize
    @json = JSON.parse(File.read("#{Rails.root}/data/lti_examples-2013-10-10T22:49:29Z.json"))
  end

  def run
    self.wipeout
    self.import_tags
    self.import_organizations

    user = User.where(twitter_nickname: "whitmer").first

    @json['apps'].each do |data|
      puts "IMPORTING #{data['id']}"
      puts " --config"
      configuration = self.import_lti_app_configuration(user, data)

      puts " --app"
      app = self.import_lti_app(user, configuration, data)
    end

    @json['app_review'].each do |data|
      review = import_review(data)
    end

    self.reassign_lti_apps

    puts "DONE"
  end

  def wipeout
    ApiKey.destroy_all
    Authentication.destroy_all
    Tag.destroy_all
    Organization.destroy_all
    User.destroy_all
    LtiAppConfiguration.destroy_all
    LtiApp.all.each { |a| a.destroy! }
    Review.destroy_all
    RegistrationCode.destroy_all
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
    #data['app_type'] = 'custom' Don't import anything
    #data['app_type'] = 'data' Don't import anything
    case data['app_type']
      when 'custom', 'data'
        puts " --referencing an external configuration"
        return nil

      when 'open_launch'
        puts " --pulling XML from #{data['config_url']}"
        lti_app_configuration = LtiAppConfiguration.create_from_url(user.id, data['config_url'])

      when 'by_hand', nil
        puts " --constructing config from dump"
        lti_app_configuration = LtiAppConfiguration.new(user_id: user.id)

        cartridge = EA::Cartridge.new
        cartridge.title               = data['name']
        cartridge.description         = ReverseMarkdown.parse(data['short_description'].present? ? data['short_description'] : data['description'])
        cartridge.icon_url            = edu_appify_link(data['icon_url'].is_a?(Array) ? data['icon_url'].first : data['icon_url'])
        cartridge.launch_url          = edu_appify_link(data['open_launch_url'] || data['launch_url'])
        cartridge.tool_id             = data['id']
        cartridge.text                = data['variable_name'] || data['name']
        cartridge.default_width       = data['width'].to_i if data['width'].present?
        cartridge.default_height      = data['height'].to_i if data['height'].present?
        cartridge.privacy_level       = data['privacy_level']
        cartridge.domain              = data['domain']

        # Custom Fields
        data['custom_fields'].each do |k, v|
          cartridge.custom_fields << EA::CustomField.new( name: k, value: v )
        end if data['custom_fields'].present?

        cartridge.optional_launch_types = []

        # Config Options
        # Check config options for optional navigation elements
        data['config_options'].each do |opt|
          name = opt['name']
          if ['editor_button', 'resource_selection', 'homework_submission', 'course_nav', 'account_nav', 'user_nav'].include? name
            name = 'course_navigation' if name == 'course_nav'
            name = 'account_navigation' if name == 'account_nav'
            name = 'user_navigation' if name == 'user_nav'
            cartridge.optional_launch_types << name
          end
        end if data['config_options'].present?

        # Canvas Extensions
        data['extensions'].each do |extension|
          case extension
            when 'editor_button'
              cartridge.editor_button = EA::ModalExtension.new(enabled: true)
            when 'resource_selection'
              cartridge.resource_selection = EA::ModalExtension.new(enabled: true)
            when 'homework_submission'
              cartridge.homework_submission = EA::ModalExtension.new(enabled: true)
            when 'course_nav'
              cartridge.course_navigation = EA::NavigationExtension.new(enabled: true, text: data['course_nav_link_text'])
            when 'account_nav'
              cartridge.account_navigation = EA::NavigationExtension.new(enabled: true, text: data['account_nav_link_text'])
            when 'user_nav'
              cartridge.user_navigation = EA::NavigationExtension.new(enabled: true, text: data['user_nav_link_text'])
          end
        end if data['extensions'].present?

        lti_app_configuration.config = cartridge.as_json.delete_if{|k,v| v.blank?}
        lti_app_configuration.save
      end


    if !lti_app_configuration
      puts " **failed to import configuration"
    elsif lti_app_configuration.errors.count > 0
      puts lti_app_configuration.errors.inspect
    end

    return lti_app_configuration
  end

  def import_lti_app(user, configuration, data)
    app = LtiApp.new()
    app.lti_app_configuration_id = configuration.id if configuration
    app.config_xml_url           = data['config_url'] unless configuration
    app.user_id                  = user.id
    app.name                     = data['name']
    app.status                   = data['pending'] == true ? 'pending' : 'active'
    app.short_name               = data['id'].strip
    app.short_description        = ReverseMarkdown.parse(data['short_description'])
    app.description              = ReverseMarkdown.parse(data['description'])
    app.testing_instructions     = data['test_instructions']
    app.author_name              = data['author_name']
    app.app_type                 = data['app_type']
    app.support_url              = data['support_link']
    app.ims_cert_url             = data['ims_link']
    app.requires_secret          = !data['any_key']
    app.config_url               = edu_appify_link(data['config_url'])
    app.preview_url              = edu_appify_link(data['preview'] ? data['preview']['url'] : nil)
    app.banner_image_url         = edu_appify_link(data['banner_url'])
    app.logo_image_url           = edu_appify_link(data['logo_url'])
    app.is_public                = true
    
    if app.save
      @map = maps
      if data['categories'].is_a? Array
        data['categories'].each do |val|
          # puts "CAT: #{val}"
          app.tags << @map[:categories][val]
        end
      end

      if data['levels'].is_a? Array
        data['levels'].each do |val|
          # puts "LVL: #{val}"
          app.tags << @map[:education_levels][val]
        end
      end

      if data['extensions'].is_a? Array
        data['extensions'].each do |val|
          # puts "EXT: #{val}"
          app.tags << @map[:extensions][val]
        end
      end

      if data['only_works'].is_a? Array
        data['only_works'].each do |val|
          app.tags << @map[:platforms][val.strip.gsub('canvas','Canvas')]
        end
      end

      if data['beta'] == true
        app.tags << @map[:categories]['Beta']
      end

      # Config Options
      # Add custom config params
      data['config_options'].each do |opt|
        name = opt['name']
        unless ['editor_button', 'resource_selection', 'homework_submission', 'course_nav', 'account_nav', 'user_nav'].include? name
          app.config_options.create(
            name:          name,
            default_value: opt['value'],
            is_required:   opt['required'],
            description:   ReverseMarkdown.parse(opt['description']),
            param_type:    opt['type']
          )
        end
      end if data['config_options'].present?

    else
      puts "ERROR: #{data['name']} - #{app.errors.full_messages.inspect}"
    end

    return app
  end

  def import_review(data)
    organizations = {
      1 => Organization.where(name: "LTI-Examples").first,
      6 => Organization.where(name: "Canvas Cloud").first
    }

    app = LtiApp.where(short_name: data["tool_id"]).first

    if app
      user = User.where(twitter_nickname: data["user_id"]).first_or_create({
          name: data["user_name"],
          avatar_url: data["user_avatar_url"],
          url: data["url"],
          is_omniauthing: true
      })
      membership = Membership.where(organization_id: organizations[data["external_access_token_id"]], user_id: user.id).first_or_create({
        is_admin: true
      })

      review = app.reviews.build({
        rating: data["rating"],
        comments: data["comments"],
        lti_app_id: app.id,
        user_id: user.id,
        membership_id: membership.id,
        created_at: Date.parse(data["created_at"])
      })

      if review.save
        # puts "REVIEW: #{review.id}"
      else
        puts "ERROR: #{data['tool_id']} - #{review.errors.full_messages.inspect}"
      end
      review
    else
      puts "App does not exist: #{data['tool_id']}"
    end
  end

  def reassign_lti_apps
    @json["permissions"].each do |perm|
      apps = perm["apps"]
      if apps.present? && apps != 'any'
        user = User.where(twitter_nickname: perm["username"][1..-1]).first
        if user
          apps.split(',').each do |short_name|
            app = LtiApp.where(short_name: short_name).first
            if app
              app.user_id = user.id
              app.organization_id = user.organizations.first.try(:id)
              app.save
              puts "Changed ownership of #{short_name} to #{user.id}"
            end
          end
        end
      end
    end
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

    platform_map = {}
    Tag.platforms.each do |t|
      platform_map[t.name] = t
    end

    extension_map = {}
    Tag.lms_extensions.each do |t|
      extension_map[t.short_name] = t
    end

    return {
      categories: category_map,
      education_levels: education_level_map,
      platforms: platform_map,
      extensions: extension_map
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