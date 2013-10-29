require 'spec_helper'

describe "Site Navigation" do
  describe "ensure header and side navigation works", type: :feature do
    before :each do
      visit login_path
    end

    it "click logo goes to apps" do
      find('a.navbar-brand').click
      expect(page).to have_content 'An open LTI app collection. Browse apps below or learn more'

      within(:css, "#header") do
        click_link 'Login'
      end
      expect(page).to have_content 'or using your email and password below'
    end

    it "click Apps" do
      within(:css, "#header") do
        click_link 'Apps'
      end
      expect(page).to have_content 'An open LTI app collection. Browse apps below or learn more'
    end

    it "click Tutorials" do
      within(:css, "#header") do
        click_link 'Tutorials'
      end
      page.title.should include "Tutorials"
    end

    describe "Tutorials section", type: :feature do
      before :each do
        within(:css, "#header") do
          click_link 'Tutorials'
        end
      end

      ["Canvas", "Moodle", "Blackboard", "Desire2Learn", "Sakai"].each do |name|
        it "click #{name}" do
          within(:css, "#alt-nav") do
            click_link name
          end
          page.title.should include name
        end
      end
    end

    describe "docs" do
      before :each do
        within(:css, "#header") do
          click_link 'Docs'
        end
      end

      describe "basics" do
        ["Introduction", "Building an LTI App", "POST Parameters", "Other Resources"].each do |name|
          it "click #{name}" do
            within(:css, '#alt-nav ul[rel="basics"]') do
              click_link name
              page.title.should include name
            end
          end
        end
      end

      describe "extensions" do
        ["Introduction", "Content", "Result Data", "Canvas: Navigation", "Canvas: WYSIWYG", 
          "Canvas: Link Selection", "Canvas: Homework Submission"].each do |name|
          it "click #{name}" do
            within(:css, '#alt-nav ul[rel="extensions"]') do
              click_link name
              page.title.should include name
            end
          end
        end
      end

      describe "api" do
        ["Introduction", "App List", "App Details", "Contributing Reviews", "Retrieving Reviews"].each do |name|
          it "click #{name}" do
            within(:css, '#alt-nav ul[rel="api"]') do
              click_link name
              page.title.should include name
            end
          end
        end
      end

    end

  end
end
