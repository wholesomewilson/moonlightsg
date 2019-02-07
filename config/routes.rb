Rails.application.routes.draw do

  get 'profiles/show'

  get 'summary/show'

  root 'lessons#index'

  get 'create' => 'lessons#new'

  get 'guest/create'

  get 'guest/update'

  get 'guest/destroy'

  get "/lessons/add_location" => "lessons#add_location"

  get "/lessons/add_location_edit" => "lessons#add_location_edit"

  get 'summary/show_new_guest' => 'summary#show_new_guest'

  get 'lessons/new' => 'lessons#new'

  get 'lessons/update' => 'lessons#update'

  post '/push' => 'notifications#push'

  post '/message' => 'notifications#message'

  post '/subscribe' => 'notifications#subscribe'

  get "/lessons/remove_image" => "lessons#remove_image"

  get "/lessons/add_image" => "lessons#add_image"

  get "/admin" => "admin#index"

  get "/conversations/read_update" => "conversations#read_update"

  get "/conversations/message_push" => "conversations#message_push"

  get "lessons/owner_cancel" => "lessons#owner_cancel"

  post "cash_out" => "admin#cash_out"

  put "update_cash_out" => "admin#update_cash_out"



  resources :summary
  resources :job_photo
  resources :locations
  resource :profiles
  resource :reviews

  resources :conversations do
    resources :messages
  end

  resources :rsvps do
    collection do
       post 'add_location'
    end
  end

  resources :lessons do
    collection do
      get 'search'
    end
    member do
      post 'create_question'
    end
    member do
      post 'create_answer'
    end
    member do
      post 'create_rsvp'
    end
  end

  devise_for :users, controllers: {
          registrations: 'users/registrations',
          sessions: 'users/sessions',
          confirmations: 'users/confirmations'
  }
  devise_scope :user do
    get 'users', to: 'users/registrations#new'
    get 'signup', to: 'users/registrations#new'
    get 'contact_info', to: 'users/registrations#contact_info'
    get 'close_account', to: 'users/registrations#close_account'
    get 'password', to: 'users/registrations#edit'
    get 'account_settings', to: 'users/registrations#edit'
    get 'lesson_owner', to: 'users/registrations#lesson_owner'
    get 'lesson_solver', to: 'users/registrations#lesson_solver'
    get 'login', to: 'users/sessions#new'
    delete 'logout', to: 'users/sessions#destroy'
    get 'forgetpassword', to: 'users/passwords#new'
    get 'about_yourself', to: 'users/registrations#about_yourself'
    get 'wallet', to: 'users/registrations#wallet'
    post "wallet/create_transaction" => "users/registrations#create_transaction"
  end

  #match '*path' => redirect('/'), via: :get
end
