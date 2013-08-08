# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lti_app do
    user nil
    short_name "MyString"
    name "MyString"
    description "MyText"
    status "MyString"
    testing_instructions "MyText"
    support_url "MyString"
    author_name "MyString"
    is_public false
    app_type "MyString"
    ims_cert_url "MyString"
    preview_url "MyString"
    config_url "MyString"
    data_url "MyString"
    cartridge ""
    banner_image_url "MyString"
    logo_image_url "MyString"
    short_description "MyString"
  end
end
