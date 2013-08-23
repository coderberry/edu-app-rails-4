namespace :import do

  task :all => :environment do
    Rake::Task["import:wipeout"].execute
    Rake::Task["import:organizations"].execute
    Rake::Task["import:lti_apps"].execute
    Rake::Task["import:reviews"].execute
  end

  task :wipeout => :environment do
    Organization.destroy_all
    User.destroy_all
    LtiApp.destroy_all
    Review.destroy_all
  end

  task :test => :environment do
    json = JSON.parse(File.read("#{Rails.root}/data/dump.json"))

    json['apps'].each do |data|

      lti_app_configuration = LtiAppConfiguration.new(user_id: 1, short_name: data['id'])

      cartridge = EA::Cartridge.new
      cartridge.title       = data['name']
      cartridge.description = data['short_description'].present? ? data['short_description'] : data['description']
      cartridge.icon_url    = data['icon_url'].is_a?(Array) ? data['icon_url'].first : data['icon_url']

      if cartridge.icon_url.present? && cartridge.icon_url =~ /^\//
        cartridge.icon_url = "http://www.edu-apps.org#{cartridge.icon_url}"
      end

      cartridge.launch_url  = data['open_launch_url'] || data['launch_url']
      if cartridge.launch_url.present? && cartridge.launch_url =~ /^\//
        cartridge.launch_url = "http://www.edu-apps.org#{cartridge.launch_url}"
      end

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

      puts "------------------------------------------------------------------------------------------------"

    end
  end

  task :organizations => :environment do
    json = JSON.parse(File.read("#{Rails.root}/data/dump.json"))

    json["external_access_token"].each do |node|
      organization = Organization.where(name: node["name"]).first_or_create( url: node["site_url"] )
      organization.api_keys.where(access_token: node["token"]).first_or_create

      json["permissions"].each do |perm|
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

    json["permissions"].each do |perm|
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

  task :lti_apps => :environment do
    raise "You must first run `rake db:seed` to import the tags" if Tag.count == 0

    json = JSON.parse(File.read("#{Rails.root}/data/dump.json"))

    success = 0
    failure = 0
    json["apps"].each do |node|
      extension_map = {}
      Tag.extensions.each do |t|
        extension_map[t.short_name] = t
      end

      category_map = {}
      Tag.categories.each do |t|
        category_map[t.name] = t
      end

      education_level_map = {}
      Tag.education_levels.each do |t|
        education_level_map[t.name] = t
      end

      app = LtiApp.new
      app.user_id              = 1 # hardcoded for now
      app.name                 = node['name']
      app.status               = node['pending'] == true ? 'pending' : 'active'
      app.short_name           = node['id']
      app.short_description    = node['short_description']
      app.description          = node['description']
      app.testing_instructions = node['test_instructions']
      app.author_name          = node['author_name']
      app.app_type             = node['app_type']
      app.support_url          = node['support_link']
      app.config_url           = node['config_url']
      app.preview_url          = node['preview'] ? node['preview']['url'] : nil
      app.ims_cert_url         = node['ims_link']

      if app.config_url.present?
        unless app.config_url =~ /http/
          app.config_url = "http://www.edu-apps.org#{node['config_url']}"
        end
      end

      if app.preview_url.present?
        unless app.preview_url =~ /http/
          app.preview_url = "http://www.edu-apps.org#{app.preview_url}"
        end
      end

      if node['banner_url'].present?
        if node['banner_url'] =~ /http/
          app.banner_image_url = node['banner_url']
        else
          app.banner_image_url = "http://www.edu-apps.org#{node['banner_url']}"
        end
      end

      if node['logo_url'].present?
        if node['logo_url'] =~ /http/
          app.logo_image_url = node['logo_url']
        else
          app.logo_image_url = "http://www.edu-apps.org#{node['logo_url']}"
        end
      end

      if node['icon_url'].present?
        if node['icon_url'] =~ /http/
          app.icon_image_url = node['icon_url']
        else
          app.icon_image_url = "http://www.edu-apps.org#{node['icon_url']}"
        end
      end
      
      if app.save

        # Save the cartridge
        puts app.config_url
        begin
          uri = URI.parse(app.config_url)
          http = Net::HTTP.new(uri.host, uri.port)
          if uri.scheme == 'https'
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          xml = http.request(Net::HTTP::Get.new(uri.request_uri)).body
          app.cartridge = Hash.from_xml(xml).to_json
          app.save
        rescue => ex
          puts ex.message
        end

        if node['extensions'].is_a? Array
          node['extensions'].each do |val|
            puts "EXT: #{val}"
            app.tags << extension_map[val]
          end
        end

        if node['categories'].is_a? Array
          node['categories'].each do |val|
            puts "CAT: #{val}"
            app.tags << category_map[val]
          end
        end

        if node['levels'].is_a? Array
          node['levels'].each do |val|
            puts "LVL: #{val}"
            app.tags << education_level_map[val]
          end
        end

        if node['beta'] == true
          app.tags << category_map['Beta']
        end

        success += 1
      else
        puts "ERROR: #{node['name']} - #{app.errors.full_messages.inspect}"
        failure += 1
      end
    end
    puts "#{success} added with #{failure} failures"
  end

  task :reviews => :environment do
    json = JSON.parse(File.read("#{Rails.root}/data/dump.json"))
    json["app_review"].each do |node|
      organizations = {
        1 => Organization.where(name: "LTI-Examples").first,
        6 => Organization.where(name: "Canvas Cloud").first
      }

      app = LtiApp.where(short_name: node["tool_id"]).first
      user = User.where(twitter_nickname: node["user_id"]).first_or_create({
          name: node["user_id"],
          is_omniauthing: true
      })
      membership = Membership.where(organization_id: organizations[node["external_access_token_id"]], user_id: user.id).first_or_create({
        is_admin: true
      })

      review = app.reviews.build({
        rating: node["rating"],
        comments: node["comments"],
        lti_app_id: app.id,
        user_id: user.id,
        membership_id: membership.id
      })

      if review.save
        puts "REVIEW: #{review.id}"
      else
        puts "ERROR: #{node['tool_id']} - #{review.errors.full_messages.inspect}"
      end

    end
  end

end