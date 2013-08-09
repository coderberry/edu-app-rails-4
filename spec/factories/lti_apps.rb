# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_app do
    short_name "app_id"
    name "Long App Name"
    status "active"
  end
end
