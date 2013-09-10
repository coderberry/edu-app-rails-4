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

    @json['app_review'].each do |data|
      review = import_review(data)
    end

    self.reassign_lti_apps

    puts "DONE"
  end

  def wipeout
    Tag.destroy_all
    Organization.destroy_all
    User.destroy_all
    LtiAppConfiguration.destroy_all
    LtiApp.destroy_all
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
    lti_app_configuration = LtiAppConfiguration.new(user_id: user.id)

    cartridge = EA::Cartridge.new
    cartridge.title               = data['name']
    cartridge.description         = ReverseMarkdown.parse(data['short_description'].present? ? data['short_description'] : data['description'])
    cartridge.icon_url            = edu_appify_link(data['icon_url'].is_a?(Array) ? data['icon_url'].first : data['icon_url'])
    cartridge.launch_url          = edu_appify_link(data['open_launch_url'] || data['launch_url'])
    cartridge.tool_id             = data['id']
    cartridge.text                = data['course_nav_link_text'] || data['user_nav_link_text'] || data['account_nav_link_text']
    cartridge.default_width       = data['width'].to_i if data['width'].present?
    cartridge.default_height      = data['height'].to_i if data['height'].present?
    cartridge.privacy_level      = data['privacy_level']
    cartridge.domain              = data['domain']
    cartridge.editor_button       = EA::ModalExtension.new(name: 'editor_button')
    cartridge.resource_selection  = EA::ModalExtension.new(name: 'resource_selection')
    cartridge.homework_submission = EA::ModalExtension.new(name: 'homework_submission')
    cartridge.course_navigation   = EA::NavigationExtension.new(name: 'course_navigation')
    cartridge.account_navigation  = EA::NavigationExtension.new(name: 'account_navigation')
    cartridge.user_navigation     = EA::NavigationExtension.new(name: 'user_navigation')

    # Custom Fields
    data['custom_fields'].each do |k, v|
      cartridge.custom_fields << EA::CustomField.new( name: k, value: v )
    end if data['custom_fields'].present?

    optional_extensions = []

    # Config Options
    data['config_options'].each do |opt|
      name = opt['name']
      if ['editor_button', 'resource_selection', 'homework_submission', 'course_nav', 'account_nav', 'user_nav', 'course_navigation', 'account_navigation', 'user_navigation'].include? name
        name = 'course_navigation' if name == 'course_nav'
        name = 'account_navigation' if name == 'account_nav'
        name = 'user_navigation' if name == 'user_nav'
        optional_extensions << name
      else
        cartridge.config_options << EA::ConfigOption.new( name:          name,
                                                          default_value: opt['value'],
                                                          is_required:   opt['required'],
                                                          description:   ReverseMarkdown.parse(opt['description']),
                                                          type:          opt['type'] )
      end
    end if data['config_options'].present?

    # Canvas Extensions
    data['extensions'].each do |extension|
      case extension
        when 'editor_button'
          cartridge.editor_button.is_enabled = true
          cartridge.editor_button.is_optional = (optional_extensions.include? extension)
        when 'resource_selection'
          cartridge.resource_selection.is_enabled = true
          cartridge.resource_selection.is_optional = (optional_extensions.include? extension)
        when 'homework_submission'
          cartridge.homework_submission.is_enabled = true
          cartridge.homework_submission.is_optional = (optional_extensions.include? extension)
        when 'course_nav'
          cartridge.course_navigation.is_enabled = true
          cartridge.course_navigation.is_optional = (optional_extensions.include? extension)
        when 'account_nav'
          cartridge.account_navigation.is_enabled = true
          cartridge.account_navigation.is_optional = (optional_extensions.include? extension)
        when 'user_nav'
          cartridge.user_navigation.is_enabled = true
          cartridge.user_navigation.is_optional = (optional_extensions.include? extension)
      end
    end if data['extensions'].present?

    puts cartridge.as_json

    lti_app_configuration.config = cartridge.as_json
    unless lti_app_configuration.save
      puts lti_app_configuration.errors.inspect
    end

    return lti_app_configuration
  end

  def import_lti_app(user, configuration, data)
    app = LtiApp.new(lti_app_configuration_id: configuration.id)
    app.user_id                  = user.id
    app.name                     = data['name']
    app.status                   = data['pending'] == true ? 'pending' : 'active'
    app.short_name               = data['id']
    app.short_description        = ReverseMarkdown.parse(data['short_description'])
    app.description              = ReverseMarkdown.parse(data['description'])
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

  def import_review(data)
    organizations = {
      1 => Organization.where(name: "LTI-Examples").first,
      6 => Organization.where(name: "Canvas Cloud").first
    }

    app = LtiApp.where(short_name: data["tool_id"]).first
    user = User.where(twitter_nickname: data["user_id"]).first_or_create({
        name: data["user_id"],
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
      membership_id: membership.id
    })

    if review.save
      puts "REVIEW: #{review.id}"
    else
      puts "ERROR: #{data['tool_id']} - #{review.errors.full_messages.inspect}"
    end
    review
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