# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :review do
    association :lti_app, factory: :lti_app, strategy: :create
    association :user, factory: :user, strategy: :create
    rating 5
    comments "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Dignissimos, quam, mollitia, veritatis, officia facere impedit repudiandae hic necessitatibus temporibus aliquid expedita tempora beatae reprehenderit. In velit excepturi tempore fugit laborum."
  end
end
