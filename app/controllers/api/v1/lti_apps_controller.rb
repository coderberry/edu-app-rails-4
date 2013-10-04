module Api
  module V1
    class LtiAppsController < BaseController
      def index
        # Get a list of lti apps for the tags
        lti_app_ids = []

        category = Tag.where(id: params[:category]).first
        category_app_ids = category.lti_apps.pluck(:id) if category

        education_level = Tag.where(id: params[:education_level]).first
        education_level_app_ids = education_level.lti_apps.pluck(:id) if education_level

        if category_app_ids.present? && education_level_app_ids.present?
          lti_app_ids = (category_app_ids & education_level_app_ids).uniq
        elsif category_app_ids.present?
          lti_app_ids = category_app_ids
        elsif education_level_app_ids.present?
          lti_app_ids = education_level_app_ids
        else
          lti_app_ids = nil
        end

        # Stub the sql
        lti_apps = LtiApp.where("1 = 1")

        # Apply text filter
        filter = params[:filter]
        if filter.present?
          lti_apps = lti_apps.where("name ilike ?", "%#{filter}%")
        end

        # Remove any apps that are not whitelisted in the organization (if present)
        whitelisted_ids = []
        @organization = organization
        if @organization
          whitelisted_ids = @organization.approved_app_ids
        end

        if whitelisted_ids.present? && lti_app_ids.present?
          lti_apps = lti_apps.where("id in (?)", (whitelisted_ids & lti_app_ids))
        elsif lti_app_ids.present?
          lti_apps = lti_apps.where("id in (?)", lti_app_ids)
        elsif whitelisted_ids.present?
          lti_apps = lti_apps.where("id in (?)", whitelisted_ids)
        end

        lti_apps = lti_apps.inclusive.include_rating.include_total_ratings.include_tag_id_array

        case params[:sort]
        when 'name'
          sort = 'name ASC'
        when 'rating'
          sort = 'average_rating DESC NULLS LAST, total_ratings DESC'
        when 'popular'
          # unsure what to do here till we have a way of tracking usage
        when 'recent'
          sort = 'created_at DESC'
        end

        lti_apps = lti_apps.public.active.order(sort).load
        render json: lti_apps
      end

      def show
        whitelisted_ids = []
        @organization = organization
        if @organization
          whitelisted_ids = @organization.approved_app_ids
        end
        if whitelisted_ids.present?
          lti_app = LtiApp.inclusive.include_rating.include_total_ratings.include_tag_id_array.where("id in (?)", whitelisted_ids).where(short_name: params[:id]).first
        else
          lti_app = LtiApp.inclusive.include_rating.include_total_ratings.include_tag_id_array.where(short_name: params[:id]).first
        end
        if lti_app
          render json: lti_app, root: false
        else
          head 404
        end
      end
    end
  end
end
