Rails.application.routes.draw do

	root to: "crawler#welcome"

	scope '/api' do
		scope '/v1' do
			# Crawler
			scope '/crawler' do
				get '/poder_judicial_civil' => 'crawler#poder_judicial_civil'
				get '/poder_judicial_civil/:search' => 'crawler#poder_judicial_civil'
				get '/hello' => 'crawler#hello'
			end
		end
	end

end
