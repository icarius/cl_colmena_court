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
		@ingresados = Case.where(estado_colmena: 'ingresado').count
		@notificados = Case.where(estado_colmena: 'notificado').count
		@enviados = Case.where(estado_colmena: 'enviadoexterno').count
		@aceptados = Case.where(estado_colmena_situacion: 'aceptado').count
		@aceptados_obs = Case.where(estado_colmena_situacion: 'aceptadoobs').count
		@rechazados = Case.where(estado_colmena_situacion: 'rechazado').count
		@traspasados = Case.where(estado_colmena_situacion: 'traspasadooni').count
	end

	def index
		if params.has_key?(:txtsearch)
			@cases = Case.where('caratulado COLLATE UTF8_GENERAL_CI LIKE :search OR corte COLLATE UTF8_GENERAL_CI LIKE :search', search: "%#{params['txtsearch']}%").paginate(page: params[:page], :per_page => 30).order('id DESC')
		elsif params.has_key?(:estadocolmena)
			# Diccionario
			# ingresado
			# notificado
			# enviadoexterno
			@cases = Case.where(estado_colmena: params['estadocolmena']).paginate(page: params[:page], :per_page => 30).order('id DESC')
		elsif params.has_key?(:estadocolmenasituacion)
			# Diccionario
			# aceptado
			# aceptadoobs
			# rechazado
			# traspasadooni
			@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).paginate(page: params[:page], :per_page => 30).order('id DESC')
		else
			@cases = Case.paginate(page: params[:page], :per_page => 30).order('id DESC')
		end
	end

	def show
		@case = Case.find_by_id(params[:id])
	end

	def update_estado
		Case.update(params[:id_caso], estado_colmena: params[:estado_colmena])
		render :json => { :status => true, :estado_colmena => params[:estado_colmena] }, :status => 200
	end

	def update_situacion
		Case.update(params[:id_caso], estado_colmena_situacion: params[:estado_colmena_situacion])
		render :json => { :status => true, :estado_colmena_situacion => params[:estado_colmena_situacion] }, :status => 200
	end

end
