class CaseController < ApplicationController

	def welcome
		render :json => { :status => true, :message => "Colmena court." }, :status => 200
	end

end
