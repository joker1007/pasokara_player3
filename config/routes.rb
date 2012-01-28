PasokaraPlayerRails3::Application.routes.draw do
  devise_for :users, :controllers => {:sessions => 'custom_devise/sessions', :registrations => 'custom_devise/registrations'}, :skip => [:sessions, :registrations]
  devise_scope :user do
    get '/users/sign_in', :to => 'custom_devise/sessions#new', :as => :new_user_session
    post '/users/sign_in', :to => 'custom_devise/sessions#create', :as => :user_session
    get '/users/sign_out', :to => 'custom_devise/sessions#destroy', :as => :destroy_user_session
    get '/users/switch/:id', :to => 'custom_devise/sessions#switch', :as => :switch_user_session

    get '/users/cancel', :to => 'custom_devise/registrations#cancel', :as => :cancel_user_registration
    get '/users/sign_up', :to => 'custom_devise/registrations#new', :as => :new_user_registration
    post '/users', :to => 'custom_devise/registrations#create', :as => :user_registration
    get '/users/edit', :to => 'custom_devise/registrations#edit', :as => :edit_user_registration
    put '/users', :to => 'custom_devise/registrations#update'
    delete '/users', :to => 'custom_devise/registrations#destroy'
  end

  authenticate :user do
    mount Resque::Server.new, :at => "/resque"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.
  resources :directories, :only => [:index, :show]
  resources :history, :only => [:index]
  resources :nico_lists
  resources :queues, :only => [:index, :destroy] do
    collection do
      get 'deque'
      get 'last'
    end
  end

  resources :tags, :only => [:index] do
    collection do
      post 'search'
    end
  end

  resources :pasokaras, :only => [:index, :show] do
    member do
      get 'thumb'
      get 'queue'
      get 'preview'
      get 'raw_file'
      get 'movie_path'
      get 'encode_status'
      get 'add_favorite'
      get 'remove_favorite'
    end

    collection do
      get 'search'
      post 'search'
      get 'favorite'
      post 'favorite'
      get 'play'
      get 'change_encode_mode'
    end
  end

  match 'help/usage' => 'help#usage'

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "directories#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
