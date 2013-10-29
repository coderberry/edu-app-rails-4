require 'spec_helper'

describe "Sessions" do
  describe "GET /users/new", type: :feature do
    it "create account with bad email" do
      visit new_user_path
      expect(page).to have_content 'or register below'
      fill_in 'user_name', with: 'Joe Blow'
      fill_in 'user_email', with: 'joe.blow'
      fill_in 'user_password', with: 'supersecret'
      fill_in 'user_password_confirmation', with: 'supersecret'
      click_button 'Register'
      expect(page).to have_content 'Email is invalid'
    end

    it "create account with existing email" do
      User.create(
        is_registering: true,
        name: 'Foo Bar',
        email: 'foo@example.com',
        password: 'secret',
        password_confirmation: 'secret')
      visit new_user_path
      expect(page).to have_content 'or register below'
      fill_in 'user_name', with: 'Joe Blow'
      fill_in 'user_email', with: 'foo@example.com'
      fill_in 'user_password', with: 'supersecret'
      fill_in 'user_password_confirmation', with: 'supersecret'
      click_button 'Register'
      expect(page).to have_content 'Email has already been taken'
    end

    it "creates an account" do
      visit new_user_path
      expect(page).to have_content 'or register below'
      fill_in 'user_name', with: 'Joe Blow'
      fill_in 'user_email', with: 'joe.blow@instructure.com'
      fill_in 'user_password', with: 'supersecret'
      fill_in 'user_password_confirmation', with: 'supersecret'
      click_button 'Register'
      expect(page).to have_content 'Welcome Joe!'

      click_link 'Logout'
      expect(page).to have_content 'Signed out!'
    end
  end

  describe "GET /login", type: :feature do
    before :each do
      @user = User.create(
        is_registering: true,
        name: 'Foo Bar',
        email: 'foo@example.com',
        password: 'secret',
        password_confirmation: 'secret')
    end

    it "logs in" do
      visit login_path
      fill_in 'email', with: 'foo@example.com'
      fill_in 'password', with: 'secret'
      click_button 'Login'
      expect(page).to have_content 'Logged in!'
    end
  end
end
