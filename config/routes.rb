require 'sidekiq/web'
require 'sidekiq_web_constraint'
Al::Application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api/v1"
  end

  get "/api/v1", to: "graphql#execute"
  post "/api/v1", to: "graphql#execute"
  get "/api" => redirect("https://github.com/hectorperez/agreelist/#api")

  extend SidekiqWebContraint

  constraints sidekiq_web_constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  root to: "new#index"
  get "/browse", to: "new#index", as: :new
  get "/brexit", to: "boards#brexit", as: :brexit_board
  get "/boards/brexit" => redirect("/brexit")
  post '/results' => 'home#save_email'
  get "/all" => 'statements#index', as: :all
  get "/s/:title_and_hashed_id" => "statements#deprecated_show" # deprecated
  get "/slack" => redirect("https://join.slack.com/t/agreelist/shared_invite/enQtMzQ3NjQ5NTY1MDI0LTg2ZmVmZWI2MzFlNDNjM2M2NDA5MjM4ZTA5NDYxYmVhMzAyNGZlNjE4ZWNhMDYxOWIyODM3NGE5YjM1MjlhNTU")
  resources :kpis, only: :index
  resources :statements, path: "a" do
    collection do
      post 'create_and_vote'
    end
    member do
      get 'occupations'
      get 'schools'
    end
  end
  get "/contact" => "static_pages#contact"
  get "/donors" => "static_pages#donors"
  post "/contact" => "static_pages#contact_send_email"
  resources :follows, only: [:index, :create, :destroy]
  resources :agreement_comments, only: :create
  resources :comments, only: :create
  resources :votes, only: :create
  resources :reason_categories, except: :show
  resources :professions, except: :show
  resources :reasons, only: [:edit, :update]
  resources :occupations, only: [:index, :show]
  resources :schools, only: [:index, :show]
  get "/search", to: 'searches#new', as: :new_search
  post "/search", to: 'searches#create', as: :search
  post '/vote', to: 'new#vote', as: :vote
  get '/entrepreneurs', to: 'static_pages#advice_for_entrepreneurs'
  post '/save_email' => 'individuals#save_email'
  post '/statements/quick' => 'statements#quick_create'
  resources :individuals, only: [:edit, :update, :destroy, :create], path: "" do
    member do
      get :activation
      get :search
    end
  end
  get 'signup', to: 'individuals#new', as: :signup
  match '/add_supporter' => 'agreements#add_supporter', via: [:get, :post]

  get '/contact' => 'static_pages#contact'
  get '/join' => 'static_pages#join'
  post '/emails' => 'static_pages#send_email'
  get '/about' => 'static_pages#about'
  get '/faq' => 'static_pages#faq'

  match "/auth/twitter/callback" => 'sessions#create_with_twitter', via: [:get, :post]
  match "/auth/twitter/callback2" => 'sessions#create_with_twitter', via: [:get, :post]
  get "/login" => "sessions#new", as: :login
  get "/signout" => "sessions#destroy", as: :signout
  resources :reset_password, only: [:new, :create, :edit, :update]
  resources :sessions, only: :create
  resources :agreements, path: "ag", only: [:new, :show, :create, :update, :destroy] do
    member do
      post 'upvote'
    end

    collection do
      post 'new'
    end
  end
  get '/test' => 'static_pages#polar'

  resources :agreement_positions, only: [:destroy] do
    member do
      post 'top'
      post 'bottom'
      post 'higher'
      post 'lower'
    end
  end

  get "/auth/failure" => redirect("/")
  post "/touch/:id" => 'agreements#touch', as: :touch

  post "/email" => 'static_pages#email'
  get "/terms" => "static_pages#terms", as: :terms
  get "/privacy" => "static_pages#privacy", as: :privacy
  get '/:id' => 'individuals#show', :as => :profile
end
