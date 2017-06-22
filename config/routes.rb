Rails.application.routes.draw do

	root to: "case#dashboard"

	devise_for :users

	scope '/newsovercases' do
		get '/' => 'case#newsovercases'
	end
	
	scope '/api' do
		scope '/estado' do
			get '/:id_caso/:estado_colmena' => 'case#update_estado'
		end
		scope '/situacion' do
			get '/:id_caso/:estado_colmena_situacion' => 'case#update_situacion'
		end
		scope '/study' do
			get '/crawler/:search' => 'case#study_crawler'
		end
		scope '/reporte' do
			get '/mail' => 'case#daily_mail_report'
		end
		scope '/test' do
			get '/proxy' => 'case#proxy_test'
			get '/crawler' => 'case#crawler_test'
			get '/driver' => 'case#driver_test'
			get '/circuit' => 'case#circuit_test'
			get '/news' => 'case#news_test'
			get '/getnews' => 'case#get_news_test'
			get '/getdriver' => 'case#get_driver_test'
			get '/getdriverpercent' => 'case#get_driver_test_percent'
		end
	end

	get '/reset' => 'case#reset'
	get '/start' => 'case#start'
	get '/test' => 'case#test'

	resources :case

	require 'sidekiq/web'
	authenticate :user do
		mount Sidekiq::Web => '/sidekiq'
	end

end
