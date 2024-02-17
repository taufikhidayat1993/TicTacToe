Rails.application.routes.draw do

  get '/games', to: 'pages#games'
  post '/twoplayers', to: 'pages#twoplayers'
  get '/twoplayers', to: 'pages#twoplayers'
  post 'registerplayers', to: 'pages#registerplayers'
  post '/play', to: 'pages#play'
  get '/result', to: 'pages#result'


    # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
