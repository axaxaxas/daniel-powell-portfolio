Style2::Application.routes.draw do

  resources :reports
  resources :markovs
  resources :sources

  root :to => 'home#index'

end
