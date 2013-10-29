require 'spec_helper'

describe "Organizations" do
  before :each do
    @user = User.create(
      is_registering: true,
      name: 'Foo Bar',
      email: 'foo@example.com',
      password: 'secret',
      password_confirmation: 'secret')
  end

  describe "GET /organizations", type: :feature do
    before :each do 
      visit login_path
      fill_in 'email', with: 'foo@example.com'
      fill_in 'password', with: 'secret'
      click_button 'Login'
      expect(page).to have_content 'Logged in!'
      visit organizations_path
      expect(page).to have_content 'Organizations'
    end

    describe "create" do
      before :each do
        visit new_organization_path
      end

      it "create" do
        find('button[type="submit"]').click
        expect(page).to have_content("Name can't be blank")

        fill_in 'organization_name', with: 'My Test Organization'
        find('#organization_is_list_apps_without_approval').click
        find('button[type="submit"]').click

        expect(page).to have_content 'Organization was successfully created'
      end
    end

    describe "whitelist" do
      before :each do
        5.times { FactoryGirl.create(:lti_app) }
      end

      it "should not whitelist everything if default set to false", js: true do
        @organization = Organization.create(name: "Acme", is_list_apps_without_approval: false)
        Membership.create(organization_id: @organization.id, user_id: @user.id, is_admin: true)

        visit whitelist_organization_path(@organization)
        visible_count = page.evaluate_script("$('a[data-toggle=\"lao-visible\"].btn-success:visible').length")
        hidden_count = page.evaluate_script("$('a[data-toggle=\"lao-visible\"].btn-default:visible').length")
        visible_count.should == 0
        hidden_count.should == 5
      end

      it "should whitelist everything if default set to true", js: true do
        @organization = Organization.create(name: "Acme", is_list_apps_without_approval: true)
        Membership.create(organization_id: @organization.id, user_id: @user.id, is_admin: true)
        
        visit whitelist_organization_path(@organization)
        visible_count = page.evaluate_script("$('a[data-toggle=\"lao-visible\"].btn-success:visible').length")
        hidden_count = page.evaluate_script("$('a[data-toggle=\"lao-visible\"].btn-default:visible').length")
        visible_count.should == 5
        hidden_count.should == 0
      end
    end
  end
end
