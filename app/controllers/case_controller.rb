class CaseController < ApplicationController

	def welcome
		render :json => { :status => true, :message => "Colmena court." }, :status => 200
	end

	def test
		# Case.poderjudicial_crawler('colmena')
		Case.poder_judicial_corte
		render :json => { :status => true, :message => "Colmena court test." }, :status => 200
	end

end
