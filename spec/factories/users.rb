# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name "Joe User"
    sequence(:email) {|n| "#{name.parameterize}#{rand(10000)}@example.com".downcase }
    password "secret"
    password_confirmation { password }
  end
end
