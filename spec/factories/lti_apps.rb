# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_app do
    association :user, factory: :user, strategy: :create
    sequence(:short_name) {|n| "vimeo#{rand(10000)}" }
    name "Long App Name"
    status "active"
    is_public true
    config_xml_url "http://something.com/foo.xml"
  end
end
