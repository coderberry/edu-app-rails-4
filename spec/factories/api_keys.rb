# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_key do
    tokenable_id 1
    tokenable_type "MyString"
    access_token "MyString"
    expired_at "2013-08-07 10:00:35"
  end
end
