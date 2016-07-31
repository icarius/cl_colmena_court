Rails.application.routes.draw do

	root to: "crawler#welcome"

	scope '/api' do
		scope '/v1' do
			# Crawler
			scope '/crawler' do
				get '/poder_judicial_civil' => 'crawler#poder_judicial_civil'
				get '/poder_judicial_civil/:search' => 'crawler#poder_judicial_civil'
				get '/poder_judicial_corte' => 'crawler#poder_judicial_corte'
				# get '/cases' => 'crawler#index'
			end
		end
	end

	# Cases
	scope '/case' do
		get '/index' => 'crawler#index'
	end

end
