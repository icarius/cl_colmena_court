class CaseController < ApplicationController

	# def welcome
	# 	render :json => { :status => true, :message => "Colmena court." }, :status => 200
	# end

	# def test
	# 	result = Case.poderjudicial_crawler('COLMENA')
	# 	if result
	# 		render :json => { :status => true, :message => "Colmena court test.", :result => result }, :status => 200
	# 	else
	# 		render :json => { :status => true, :message => "Colmena court test no result." }, :status => 200
	# 	end
	# end

	def dashboard
	end

	def index
		if params['txtsearch'].nil?
			@cases = Case.paginate(page: params[:page], :per_page => 20).order('id ASC')
		else
			search = params['txtsearch']
			@cases = Case.where('caratulado COLLATE UTF8_GENERAL_CI LIKE :search OR corte COLLATE UTF8_GENERAL_CI LIKE :search', search: "%#{search}%").paginate(page: params[:page], :per_page => 20).order('id DESC')
		end
	end

	def show
		@case = Case.find_by_id(params[:id])
	end

	def edit
		@case = Case.find_by_id(params[:id])
	end

	def update
	end

end
