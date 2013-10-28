require 'spec_helper'

describe "Settings" do
  before :each do
    @user = User.create(
      is_registering: true,
      name: 'Foo Bar',
      email: 'foo@example.com',
      password: 'secret',
      password_confirmation: 'secret')
  end

  describe "/settings/profile", type: :feature do
    before :each do 
      visit login_path
      fill_in 'email', with: 'foo@example.com'
      fill_in 'password', with: 'secret'
      click_button 'Login'
      expect(page).to have_content 'Logged in!'
    end

    it "updates profile information (name, website)" do
      visit edit_profile_path
      fill_in 'Full Name', with: 'Chris Rock'
      fill_in 'Website URL', with: 'http://chrisrock.com'
      click_button 'Save Changes'
      expect(page).to have_content 'Your profile has been updated successfully'
      @user.reload
      @user.name.should == 'Chris Rock'
      @user.url.should == 'http://chrisrock.com'
    end

    it "ensures that the new email address must be valid and confirmed email is saved" do
      visit edit_profile_path
      fill_in 'Email Address', with: 'foo'
      click_button 'Save Changes'
      expect(page).to have_content 'Email address is invalid. Please try again.'

      fill_in 'Email Address', with: 'bar@example.com'
      click_button 'Save Changes'
      expect(page).to have_content 'An email has been sent to you new address for confirmation'

      code = @user.registration_codes.last.code
      fill_in 'user_code', with: code
      click_button 'Save Changes'
      expect(page).to have_content 'Your profile has been updated successfully'
      @user.reload
      @user.email.should == 'bar@example.com'
    end
  end

  describe "/settings/account_settings", type: :feature do
    before :each do 
      visit login_path
      fill_in 'email', with: 'foo@example.com'
      fill_in 'password', with: 'secret'
      click_button 'Login'
      expect(page).to have_content 'Logged in!'
    end

    it "updates password" do
      visit edit_password_path
      fill_in 'user_password', with: 'asdf'
      fill_in 'user_password_confirmation', with: 'asdf'
      click_button 'Update Password'
      expect(page).to have_content 'Please fix the errors below and try again'
      expect(page).to have_content 'Password is too short (minimum is 6 characters)'

      fill_in 'user_password', with: 'asdfasdf'
      fill_in 'user_password_confirmation', with: 'asdfasdfasdf'
      click_button 'Update Password'
      expect(page).to have_content 'Please fix the errors below and try again'
      expect(page).to have_content "Password confirmation doesn't match Password"

      fill_in 'user_password', with: 'supersecret'
      fill_in 'user_password_confirmation', with: 'supersecret'
      click_button 'Update Password'
      expect(page).to have_content 'Your password has been changed successfully'
    end
  end
end