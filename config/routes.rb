EduApps::Application.routes.draw do
  
  get "/tools/xml_builder" => "xml_builder#index", as: :xml_builder
  
  resources :lti_apps, path: '/apps'

  scope "api/v1" do
    get "lti_apps" => "lti_apps#index", :defaults => { :format => "json" }
    get "lti_apps/:id" => "lti_apps#show", :defaults => { :format => "json" }
    get "lti_apps/:lti_app_id/reviews" => "reviews#index", :defaults => { :format => "json" }
    get "reviews" => "reviews#index", :defaults => { :format => "json" }

    get "cartridges" => "cartridges#index", :defaults => { :format => "json" }
    get "cartridges/:uid" => "cartridges#show", :defaults => { :format => "json" }
    post "cartridges" => "cartridges#create"
    post "cartridges/import" => "cartridges#import"
    post "cartridges/:uid" => "cartridges#update"
    delete "cartridges" => "cartridges#destroy"
  end

  resources :tags

  get "/tutorials/:page" => "static#tutorials", as: :tutorials
  get "/tutorials" => "static#tutorials"
  get "/docs/:section/:page" => "static#docs", as: :docs
  get "/docs" => "static#docs"

  get "/auth/:provider/callback" => "sessions#create"
  get "/login" => "sessions#new", as: :login
  get "/logout" => "sessions#destroy", as: :logout

  get "/settings/profile" => "users#edit", as: :edit_profile
  get "/settings/account_settings" => "users#edit_password", as: :edit_password
  patch "/settings/account_settings" => "users#update_password", as: :update_password

  get "/cartridges/:uid.xml" => "cartridges#xml"

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

  resources :users
  resources :sessions

  root "lti_apps#index"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
