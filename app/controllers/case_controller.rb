class CaseController < ApplicationController

	def welcome
		render :json => { :status => true, :message => "Colmena court." }, :status => 200
	end

	def home
	end

	def test
		result = Case.poderjudicial_crawler('COLMENA')
		if result
			render :json => { :status => true, :message => "Colmena court test.", :result => result }, :status => 200
		else
			render :json => { :status => true, :message => "Colmena court test no result." }, :status => 200
		end
	end

end
