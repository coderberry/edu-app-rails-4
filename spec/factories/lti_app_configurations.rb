# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_app_configuration do
    uid "MyString"
    config ""
    user nil
  end
end
