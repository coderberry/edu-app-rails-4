# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review do
    membership nil
    user nil
    rating 1
    comments "MyText"
    lti_app nil
  end
end
