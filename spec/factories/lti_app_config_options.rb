# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_app_config_option do
    lti_app nil
    name "MyString"
    type ""
    default_value "MyString"
    description "MyString"
    is_required false
  end
end
