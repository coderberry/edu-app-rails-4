# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_app do
    sequence(:short_name) {|n| "vimeo#{rand(10000)}" }
    name "Vimeo"

    association :user, factory: :user, strategy: :create
  end
end
