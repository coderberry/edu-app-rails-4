# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_apps_organization do
    lti_app nil
    organization nil
    is_visible false
  end
end
