# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :twitter, class:Hash do
    provider 'twitter'
    uid '1234567890'
    info {{
        'nickname' => 'nick',
        'name' => 'New User',
        'image' => 'http://www.example.com/image.png'
    }}

    initialize_with {attributes.stringify_keys}
  end

  factory :google_oauth2, class:Hash do
    provider 'google_oauth2'
    uid '0987654321'
    info {{
        'name' => 'Google User',
        'image' => 'http://www.example.com/new/image.png'
    }}

    initialize_with {attributes.stringify_keys}
  end

  factory :facebook, class:Hash do
    provider 'facebook'
    uid '1212121212'
    info {{
        'name' => 'Facebook User',
        'image' => 'http://www.example.com/facbook/image.png'
    }}

    initialize_with {attributes.stringify_keys}
  end
end
