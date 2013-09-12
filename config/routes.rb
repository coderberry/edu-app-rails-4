EduApps::Application.routes.draw do

  get 'old' => 'lti_apps#index'  

  root "ember#app_list"

  get "lti_app_configurations/index"
  get "lti_app_configurations/show"
  get "/tools/xml_builder" => "xml_builder#index", as: :xml_builder
  
  resources :lti_apps, path: '/apps' do
    collection do
      get 'my', as: :my
    end
  end

  namespace :api do
    namespace :v1 do
      resources :lti_apps
    end
  end

  scope "api/v1" do
    post "lti_app_configurations/import" => "lti_app_configurations#import"
    post "lti_app_configurations/create_from_xml" => "lti_app_configurations#create_from_xml"
    get "lti_app_configurations" => "lti_app_configurations#index", :defaults => { :format => "json" }
    get "lti_app_configurations/:uid" => "lti_app_configurations#show", :defaults => { :format => "json" }
    post "lti_app_configurations" => "lti_app_configurations#create"
    post "lti_app_configurations/:uid" => "lti_app_configurations#update"
    delete "lti_app_configurations" => "lti_app_configurations#destroy"
  end

  resources :tags

  get "/tutorials/:page" => "static#tutorials", as: :tutorials
  get "/tutorials" => "static#tutorials"
  get "/docs/:section/:page" => "static#docs", as: :docs
  get "/docs" => "static#docs"

  get "/auth/:provider/callback" => "sessions#create"
  get "/login" => "sessions#new", as: :login
  get "/logout" => "sessions#destroy", as: :logout

  resources :users
  get "/settings/profile" => "users#edit", as: :edit_profile
  put "/settings/profile" => "users#update", as: :update_profile
  get "/settings/account_settings" => "users#edit_password", as: :edit_password
  patch "/settings/account_settings" => "users#update_password", as: :update_password
  get "/settings/email_confirmation" => "users#update_email", as: :email_confirmation

  get "/configurations/:uid.xml" => "lti_app_configurations#xml", as: :lti_app_configuration_xml

  namespace :admin do
    resources :lti_apps
    resources :users
    resources :memberships
    resources :organizations
  end

  namespace :settings do
    resources :authentications
    resources :memberships do
      member do
        get :reset_api_token
        post :add_member_to_organization
        delete :remove_member_from_organization
      end
    end
  end

  resources :reviews
  resources :sessions
  resources :authentications, only: [:index] do
    member do
      get 'destroy', as: :delete # stink
    end
  end
  resources :organizations do
    resources :memberships
  end

end
