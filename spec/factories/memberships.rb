# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :membership do
    organization nil
    user nil
    remote_uid "MyString"
    is_admin false
  end
end
