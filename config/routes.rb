Rails.application.routes.draw do

  devise_for :users
	root to: "cases#welcome"

	scope '/api' do
		scope '/v1' do
			# Crawler
			scope '/crawler' do
				get '/poder_judicial_corte' => 'crawler#poder_judicial_corte'
			end
		end
	end

	# Cases
	scope '/case' do
		get '/index' => 'case#index'
	end

	# Recursos
	resources :cases

end
