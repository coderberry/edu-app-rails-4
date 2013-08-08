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
      app.banner_image_url     = node['banner_url']
      app.logo_image_url       = node['logo_url']
      app.icon_image_url       = node['icon_url']
      app.cartridge            = node['cartridge']
      if app.save

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