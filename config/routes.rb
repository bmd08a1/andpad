Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/users' => 'users#create'

  post '/login' => 'tokens#create'
  post '/refresh' => 'tokens#refresh'

  post '/companies/register' => 'companies#create'

  post '/teams' => 'teams#create'
  get '/teams' => 'teams#index'
  put '/teams/:team_id/add_member' => 'teams#add_member'
end
