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
		scope '/colmena' do
			get '/:id_caso/:id_colmena' => 'case#update_id_colmena'
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
			get '/fecha_ingreso_data' => 'case#convert_fecha_ingreso_to_date'
			get '/fix_cases' => 'case#case_fix'
			get '/regenerate_rol_rit' => 'case#regenerate_rol_rit'
			get '/generate_rol' => 'case#generate_rol'
			get '/proxy_socks5' => 'case#proxy_socks5_test'
		end
	end

	get '/reset' => 'case#reset'
	get '/start' => 'case#start'

	get '/case_export' => 'case#case_export'

	resources :case

	require 'sidekiq/web'
	authenticate :user do
		mount Sidekiq::Web => '/sidekiq'
	end

end
