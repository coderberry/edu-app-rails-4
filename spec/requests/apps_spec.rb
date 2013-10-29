require 'spec_helper'

describe "Apps" do
  before :each do
    @user = User.create(
      is_registering: true,
      name: 'Foo Bar',
      email: 'foo@example.com',
      password: 'secret',
      password_confirmation: 'secret')
  end

  describe "/apps/new", type: :feature do
    before :each do 
      visit login_path
      fill_in 'email', with: 'foo@example.com'
      fill_in 'password', with: 'secret'
      click_button 'Login'
      expect(page).to have_content 'Logged in!'
      visit new_lti_app_path
      expect(page).to have_content 'Submit an App'
    end

    it "creates an app with config options", js: true do
      find('input[name="cartridge_source"][value="xml"]').click
      fill_in 'xml', with: KITCHEN_SINK
      find('#lti_app_is_public_true').click
      fill_in 'lti_app_short_name', with: 'kitchen_sink'
      fill_in 'lti_app_name', with: 'Kitchen Sink'
      fill_in 'lti_app_author_name', with: 'Joe Blow'
      fill_in 'lti_app_preview_url', with: 'http://vimeo-lti.herokuapp.com'
      fill_in 'lti_app_banner_image_url', with: 'http://vimeo-lti.herokuapp.com/images/banner.png'
      
      find('a.add_fields').click
      page.execute_script("$('.fields tr:last input[rel=\"name\"]').val('req_w_def')")
      page.execute_script("$('.fields tr:last input[rel=\"default_value\"]').val('REQ DEF VALUE')")
      page.execute_script("$('.fields tr:last input[rel=\"description\"]').val('Required w/ Default')")
      page.execute_script("$('.fields tr:last input[rel=\"is_required\"]').click()")

      find('a.add_fields').click
      page.execute_script("$('.fields tr:last input[rel=\"name\"]').val('req_wo_def')")
      page.execute_script("$('.fields tr:last input[rel=\"description\"]').val('Required w/o Default')")
      page.execute_script("$('.fields tr:last input[rel=\"is_required\"]').click()")
      
      find('a.add_fields').click
      page.execute_script("$('.fields tr:last input[rel=\"name\"]').val('opt_w_def')")
      page.execute_script("$('.fields tr:last input[rel=\"default_value\"]').val('OPT DEF VALUE')")
      page.execute_script("$('.fields tr:last input[rel=\"description\"]').val('Optional w/ Default')")

      find('a.add_fields').click
      page.execute_script("$('.fields tr:last input[rel=\"name\"]').val('opt_wo_def')")
      page.execute_script("$('.fields tr:last input[rel=\"description\"]').val('Optional w/o Default')")
      
      click_button 'Save Changes'
      expect(page).to have_content '* Required w/ Default'
    end
  end
end
