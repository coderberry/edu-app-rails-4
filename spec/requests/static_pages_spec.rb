require 'spec_helper'

describe "static pages" do
  describe "tutorials" do
    ["canvas", "moodle", "blackboard", "desire2learn", "sakai"].each do |page_name|
      it "/tutorials/#{page_name}" do
        get "/tutorials/#{page_name}"
        response.status.should be(200)
      end
    end
  end

  describe "docs" do
    describe "basics" do
      ["index", "building_an_lti_app", "post_parameters", "other_resources"].each do |page_name|
        it "/docs/basics/#{page_name}" do
          get "/docs/basics/#{page_name}"
          response.status.should be(200)
        end
      end
    end

    describe "extensions" do
      ["index", "content", "result_data", "canvas_link_selection", "canvas_navigation", "canvas_wysiwyg", "canvas_homework_submission"].each do |page_name|
        it "/docs/extensions/#{page_name}" do
          get "/docs/extensions/#{page_name}"
          response.status.should be(200)
        end
      end
    end

    describe "api" do
      ["index", "app_list", "app_details", "app_reviews", "contributing_reviews", "retrieving_reviews"].each do |page_name|
        it "/docs/api/#{page_name}" do
          get "/docs/api/#{page_name}"
          response.status.should be(200)
        end
      end
    end
  end
end