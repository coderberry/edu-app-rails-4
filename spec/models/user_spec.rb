require 'spec_helper'

describe User do
  describe "create directly (no omniauth nor via reviews)" do
    it "requires email and password" do
      user = User.new(is_registering: true)
      user.should_not be_valid
      user.errors.has_key?(:email).should be_true
      user.errors.has_key?(:password).should be_true
    end

    it "creates a user" do
      user = User.create(
        is_registering: true,
        name: 'Foo Bar',
        email: 'foo@example.com',
        password: 'secret',
        password_confirmation: 'secret')
      user.new_record?.should be_false
    end
  end

  describe "create indirectly (via reviews)" do
    it "requires email but not password" do
      user = User.new
      user.should_not be_valid
      user.errors.has_key?(:email).should be_true
      user.errors.has_key?(:password).should be_false
    end

    it "creates a user" do
      user = User.create(
        name: 'Foo Bar',
        email: 'foo@example.com')
      user.new_record?.should be_false
    end
  end

  describe "create via omniauth" do
    it "does not require email nor password" do
      user = User.new(is_omniauthing: true)
      user.should_not be_valid
      user.errors.has_key?(:name).should be_true
      user.errors.has_key?(:email).should be_false
      user.errors.has_key?(:password).should be_false
    end

    it "creates a user" do
      user = User.create(
        is_omniauthing: true,
        name: 'Foo Bar')
      user.new_record?.should be_false
    end
  end
end
