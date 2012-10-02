Rtastic::Application.routes.draw do
  
  # Root set up
  root to: 'general#home'
  match "/search", to: 'general#search'
  match "/about", to: 'general#about'
  match "/donate", to: 'general#donate'
  match "/development", to: 'general#development_plans'
  
  resources :feedbacks, only: [:create]
  match "/feedback", to: 'general#feedback'

  # Users resources and routes
  resources :users
  resources :sessions, only: [:new, :create, :destroy]

  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  
  # Paintgraph routes
  match "/paintgraph", to: 'graph#paintgraph'
  match "/settingsgraph", to: 'graph#settingsgraph'

  # Packages routes and admin routes
  match "/overview", to: 'packages#overview'
  match "/packages/:name", to: 'packages#show', :constraints => { :name => /[0-z\.]+/ }
  match "/log", to: 'packages#log'
  match "/init", to: 'packages#init'
  match "/update", to: 'packages#update'

  #Documentation routes the constraints are there because package and function names contain dots and hyphens
  #which are not allowed by default
  match "/docs/:name", to: 'packages#documentation', :constraints => { :name => /[0-z\.-]+/ }
  match "/docs/:name/:function", to: 'packages#documentation', :constraints => { :name => /[0-z\.-]+/ , :function => /[0-z\.-]+/}
  match "/docsbuild/:name", to: 'packages#builddocs', :constraints => { :name => /[0-z\.-]+/ }

end
