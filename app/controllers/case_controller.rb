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
		if params.has_key?(:txtsearch)
			@cases = Case.where('caratulado COLLATE UTF8_GENERAL_CI LIKE :search OR corte COLLATE UTF8_GENERAL_CI LIKE :search', search: "%#{params['txtsearch']}%").paginate(page: params[:page], :per_page => 20).order('id DESC')
		elsif params.has_key?(:estadocolmena)
			@cases = Case.where('estado_colmena = :search', search: "%#{params['estadocolmena']}%").paginate(page: params[:page], :per_page => 20).order('id DESC')
		elsif params.has_key?(:estadocolmenaprocesal)
			@cases = Case.where('estado_colmena_procesal = :search', search: "%#{params['estadocolmenaprocesal']}%").paginate(page: params[:page], :per_page => 20).order('id DESC')
		else
			@cases = Case.paginate(page: params[:page], :per_page => 20).order('id DESC')
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
