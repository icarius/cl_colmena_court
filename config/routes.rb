Rails.application.routes.draw do

	root to: "case#welcome"
	devise_for :users
	
end
