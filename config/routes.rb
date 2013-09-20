EduApps::Application.routes.draw do
  root "lti_apps#index"

  # Ember application
  get "/tools/xml_builder" => "xml_builder#index", as: :xml_builder
  get "/configurations/:uid.xml" => "lti_app_configurations#xml", as: :lti_app_configuration_xml

  # static pages
  get "/about" => "static#about", as: :about
  get "/suggest" => "static#suggest", as: :suggest
  get "/tutorials/:page" => "static#tutorials", as: :tutorials
  get "/tutorials" => "static#tutorials"
  get "/docs/:section/:page" => "static#docs", as: :docs
  get "/docs" => "static#docs"

  # authentication
  resources :sessions
  get "/auth/:provider/callback" => "sessions#create"
  get "/login" => "sessions#new", as: :login
  get "/logout" => "sessions#destroy", as: :logout
  
  resources :lti_apps, path: '/apps' do
    collection do
      get 'my'
      get 'deleted'
    end
    member do
      get 'restore'
    end
  end

  namespace :api do
    namespace :v1 do
      resources :lti_apps do
        resources :reviews
      end
      resources :lti_app_configurations do
        collection do
          post 'import'
          post 'create_from_xml'
        end
      end
    end
  end

  resources :users do
    member do
      get 'edit_password'
      patch 'update_password'
    end
  end
  get "/settings/profile" => "users#edit", as: :edit_profile
  put "/settings/profile" => "users#update", as: :update_profile
  get "/settings/account_settings" => "users#edit_password", as: :edit_password
  patch "/settings/account_settings" => "users#update_password", as: :update_password
  get "/settings/email_confirmation" => "users#update_email", as: :email_confirmation


  # namespace :admin do
  #   resources :lti_apps
  #   resources :users
  #   resources :memberships
  #   resources :organizations
  # end

  # namespace :settings do
  #   resources :authentications
  #   resources :memberships do
  #     member do
  #       get :reset_api_token
  #       post :add_member_to_organization
  #       delete :remove_member_from_organization
  #     end
  #   end
  # end

  # resources :reviews
  
  resources :authentications, only: [:index] do
    member do
      get 'destroy', as: :delete # stink
    end
  end

  post 'organizations/:id/toggle_whitelist_item/:lao_id' => 'organizations#toggle_whitelist_item'
  resources :organizations do
    resources :api_keys do
      collection do
        get 'create_token'
      end
      member do
        get 'renew_token'
        get 'expire_token'
      end
    end
    resources :memberships
    member do
      get 'whitelist'
      get 'toggle_whitelist'
    end
  end

end
