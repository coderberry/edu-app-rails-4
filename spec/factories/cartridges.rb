# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cartridge do
    association :user, factory: :user, strategy: :create
    sequence(:name) {|n| "My Xml #{rand(10000)}" }
  end
end
