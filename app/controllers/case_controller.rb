class CaseController < ApplicationController

	require 'csv'

	# Re-inicia la cola de sidekiq
	def start
		require 'sidekiq/api'
		Sidekiq::Queue.new.clear
		Sidekiq::RetrySet.new.clear
		Sidekiq::ScheduledSet.new.clear
		# Inicializador para comenzar la cadena de tareas.
		SearchWorker.perform_at(10.seconds.from_now)
		# DailyMailReportWorker.perform_at(5.seconds.from_now)
		render :json => 'start'
	end

	# Re-inicia la cola de sidekiq
	def reset
		require 'sidekiq/api'
		Sidekiq::Stats.new.reset
		render :json => 'reset'
	end

	def dashboard
		@ingresados = Case.where(estado_colmena: 'ingresado').count
		@notificados = Case.where(estado_colmena: 'notificado').count
		@enviados = Case.where(estado_colmena: 'enviadoexterno').count
		@cerrados = Case.where(estado_colmena: 'cerrado').count
		@aceptados = Case.where(estado_colmena_situacion: 'aceptado').count
		@aceptados_obs = Case.where(estado_colmena_situacion: 'aceptadoobs').count
		@rechazados = Case.where(estado_colmena_situacion: 'rechazado').count
		@traspasados = Case.where(estado_colmena_situacion: 'traspasadooni').count
	end

	def index
		# if params.has_key?(:estadocolmena)
		# 	# Diccionario: ingresado, notificado, enviadoexterno.
		# 	# Si estadocolmenta es ingresado se ordena por id, sino por fecha notificado.
		# 	if params['estadocolmena'] == 'ingresado'
		# 		@cases = Case.where(estado_colmena: params['estadocolmena']).paginate(page: params[:page], :per_page => 30).order('id DESC')
		# 	else
		# 		# Si su estado no es ingresado se ordena por la fecha de modificacion. (que implica el cambio de estado) es posible que se haga necesario incoporar un nuevo dato para dar seguimiento a esta accion de forma exclusiva.
		# 		@cases = Case.where(estado_colmena: params['estadocolmena']).paginate(page: params[:page], :per_page => 30).order('updated_at DESC')
		# 	end
		# elsif params.has_key?(:estadocolmenasituacion)
		# 	# Diccionario, aceptado, aceptadoobs, rechazado, traspasadooni.
		# 	@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).paginate(page: params[:page], :per_page => 30).order('updated_at DESC')
		# elsif params.has_key?(:corte) && params.has_key?(:kind) && params.has_key?(:txtsearch) && params.has_key?(:desde) && params.has_key?(:hasta)
		if params.has_key?(:corte) && params.has_key?(:kind) && params.has_key?(:txtsearch) && params.has_key?(:desde) && params.has_key?(:hasta)
			start_date = DateTime.parse(params[:desde])
			end_date = DateTime.parse(params[:hasta])
			if params[:corte] == 'all'
				case params['kind']
				when "rut"
					litigants = CaseLitigant.where(rut: params['txtsearch']).distinct(:case_id).pluck(:case_id)
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(id: litigants).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(id: litigants).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(id: litigants).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				when "rol"
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(rol: params['txtsearch']).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(rol: params['txtsearch']).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(rol: params['txtsearch']).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				when "ningreso"
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				else
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				end
			else
				case params['kind']
				when "rut"
					litigants = CaseLitigant.where(rut: params['txtsearch']).distinct(:case_id).pluck(:case_id)
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(id: litigants).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(id: litigants).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(id: litigants).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				when "rol"
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(rol: params['txtsearch']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(rol: params['txtsearch']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(rol: params['txtsearch']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				when "ningreso"
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				else
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				end
			end
		elsif params.has_key?(:corte) && params.has_key?(:kind) && params.has_key?(:txtsearch)
			if params[:corte] == 'all'
				case params['kind']
				when "rut"
					litigants = CaseLitigant.where(rut: params['txtsearch']).distinct(:case_id).pluck(:case_id)
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(id: litigants).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(id: litigants).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(id: litigants).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				when "rol"
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(rol: params['txtsearch']).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(rol: params['txtsearch']).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(rol: params['txtsearch']).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				when "ningreso"
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				else
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				end
			else
				case params['kind']
				when "rut"
					litigants = CaseLitigant.where(rut: params['txtsearch']).distinct(:case_id).pluck(:case_id)
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(id: litigants).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(id: litigants).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(id: litigants).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				when "rol"
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where(rol: params['txtsearch']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(rol: params['txtsearch']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where(rol: params['txtsearch']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				when "ningreso"
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				else
					if params.has_key?(:estadocolmena)
						@cases = Case.where(estado_colmena: params['estadocolmena']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					elsif params.has_key?(:estadocolmenasituacion)
						@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					else
						@cases = Case.where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					end
				end
			end
		elsif params.has_key?(:corte) && params.has_key?(:desde) && params.has_key?(:hasta)
			start_date = DateTime.parse(params[:desde])
			end_date = DateTime.parse(params[:hasta])
			if params[:corte] == 'all'
				if params.has_key?(:estadocolmena)
					@cases = Case.where(estado_colmena: params['estadocolmena']).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				elsif params.has_key?(:estadocolmenasituacion)
					@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				else
					@cases = Case.where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				end
			else
				if params.has_key?(:estadocolmena)
					@cases = Case.where(estado_colmena: params['estadocolmena']).where(fecha_ingreso_como_fecha: start_date..end_date).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				elsif params.has_key?(:estadocolmenasituacion)
					@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where(fecha_ingreso_como_fecha: start_date..end_date).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				else
					@cases = Case.where(fecha_ingreso_como_fecha: start_date..end_date).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				end
			end
		elsif params.has_key?(:corte)
			if params[:corte] == 'all'
				if params.has_key?(:estadocolmena)
					@cases = Case.where(estado_colmena: params['estadocolmena']).paginate(page: params[:page], :per_page => 30).order('id DESC')
				elsif params.has_key?(:estadocolmenasituacion)
					@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).paginate(page: params[:page], :per_page => 30).order('id DESC')
				else
					@cases = Case.paginate(page: params[:page], :per_page => 30).order('id DESC')
				end
			else
				if params.has_key?(:estadocolmena)
					@cases = Case.where(estado_colmena: params['estadocolmena']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				elsif params.has_key?(:estadocolmenasituacion)
					@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				else
					@cases = Case.where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				end
			end
		else
			if params.has_key?(:estadocolmena)
				@cases = Case.where(estado_colmena: params['estadocolmena']).paginate(page: params[:page], :per_page => 30).order('id DESC')
			elsif params.has_key?(:estadocolmenasituacion)
				@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).paginate(page: params[:page], :per_page => 30).order('id DESC')
			else
				@cases = Case.paginate(page: params[:page], :per_page => 30).order('id DESC')
			end
		end
	end

	def case_export
		if params.has_key?(:estadocolmena)
			# Diccionario: ingresado, notificado, enviadoexterno.
			# Si estadocolmenta es ingresado se ordena por id, sino por fecha notificado.
			if params['estadocolmena'] == 'ingresado'
				@cases = Case.where(estado_colmena: params['estadocolmena']).paginate(page: params[:page], :per_page => 30).order('id DESC')
			else
				# Si su estado no es ingresado se ordena por la fecha de modificacion. (que implica el cambio de estado) es posible que se haga necesario incoporar un nuevo dato para dar seguimiento a esta accion de forma exclusiva.
				@cases = Case.where(estado_colmena: params['estadocolmena']).paginate(page: params[:page], :per_page => 30).order('updated_at DESC')
			end
		elsif params.has_key?(:estadocolmenasituacion)
			# Diccionario, aceptado, aceptadoobs, rechazado, traspasadooni.
			@cases = Case.where(estado_colmena_situacion: params['estadocolmenasituacion']).paginate(page: params[:page], :per_page => 30).order('updated_at DESC')
		elsif params.has_key?(:corte) && params.has_key?(:kind) && params.has_key?(:txtsearch) && params.has_key?(:desde) && params.has_key?(:hasta)
			start_date = DateTime.parse(params[:desde])
			end_date = DateTime.parse(params[:hasta])
			if params[:corte] == 'all'
				case params['kind']
				when "rut"
					litigants = CaseLitigant.where(rut: params['txtsearch']).distinct(:case_id).pluck(:case_id)
					@cases = Case.where(id: litigants).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				when "rol"
					# @cases = Case.where('lower(rol) COLLATE utf8_general_ci LIKE :search', search: "%#{params['txtsearch']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					@cases = Case.where(rol: params['txtsearch']).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				when "ningreso"
					@cases = Case.where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				else
					@cases = Case.where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				end
			else
				case params['kind']
				when "rut"
					litigants = CaseLitigant.where(rut: params['txtsearch']).distinct(:case_id).pluck(:case_id)
					@cases = Case.where(id: litigants).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				when "rol"
					# @cases = Case.where('lower(rol) COLLATE utf8_general_ci LIKE :search', search: "%#{params['txtsearch']}%".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
					@cases = Case.where(rol: params['txtsearch']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				when "ningreso"
					@cases = Case.where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				else
					@cases = Case.where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
				end
			end
		elsif params.has_key?(:corte) && params.has_key?(:kind) && params.has_key?(:txtsearch)
			if params[:corte] == 'all'
				case params['kind']
				when "rut"
					litigants = CaseLitigant.where(rut: params['txtsearch']).distinct(:case_id).pluck(:case_id)
					@cases = Case.where(id: litigants).paginate(page: params[:page], :per_page => 30).order('id DESC')
				when "rol"
					# @cases = Case.where('lower(rol) COLLATE utf8_general_ci LIKE :search', search: "%#{params['txtsearch']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					@cases = Case.where(rol: params['txtsearch']).paginate(page: params[:page], :per_page => 30).order('id DESC')
				when "ningreso"
					@cases = Case.where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				else
					@cases = Case.paginate(page: params[:page], :per_page => 30).order('id DESC')
				end
			else
				case params['kind']
				when "rut"
					litigants = CaseLitigant.where(rut: params['txtsearch']).distinct(:case_id).pluck(:case_id)
					@cases = Case.where(id: litigants).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				when "rol"
					# @cases = Case.where('lower(rol) COLLATE utf8_general_ci LIKE :search', search: "%#{params['txtsearch']}%".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
					@cases = Case.where(rol: params['txtsearch']).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				when "ningreso"
					@cases = Case.where('lower(rol_rit) COLLATE utf8_general_ci LIKE :search', search: "#{params['txtsearch']}".downcase).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				else
					@cases = Case.where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
				end
			end
		elsif params.has_key?(:corte) && params.has_key?(:desde) && params.has_key?(:hasta)
			start_date = DateTime.parse(params[:desde])
			end_date = DateTime.parse(params[:hasta])
			if params[:corte] == 'all'
				@cases = Case.where(fecha_ingreso_como_fecha: start_date..end_date).paginate(page: params[:page], :per_page => 30).order('id DESC')
			else
				@cases = Case.where(fecha_ingreso_como_fecha: start_date..end_date).where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
			end
		elsif params.has_key?(:corte)
			if params[:corte] == 'all'
				@cases = Case.paginate(page: params[:page], :per_page => 30).order('id DESC')
			else
				@cases = Case.where('lower(corte) COLLATE utf8_general_ci LIKE :search', search: "%#{params['corte']}%".downcase).paginate(page: params[:page], :per_page => 30).order('id DESC')
			end
		else
			@cases = Case.paginate(page: params[:page], :per_page => 30).order('id DESC')
		end



		
		# Ahora generamos el archivo a exportar
		respond_to do |format|
			format.html
			format.csv do
				headers['Content-Disposition'] = "attachment; filename=\"cases-report-"+Time.now.strftime("%d%m%Y-%H%M%S")+".csv\""
				headers['Content-Type'] ||= 'text/csv'
			end
		end
	end

	def case_fix
		causes = Case.all
		quantity = 0
		causes.each do |cause|
			rol = cause.ningreso.split('-')
			rol = rol[rol.length - 2]
			puts rol
			cause.rol = rol
			quantity = quantity + 1
			cause.save
		end
		render :json => { :status => true, :fixed_quantity => quantity }, :status => 200
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

	def update_id_colmena
		Case.update(params[:id_caso], id_colmena: params[:id_colmena], estado_colmena: 'enviadoexterno', estado_colmena_situacion: 'traspasadooni')
		render :json => { :status => true, :id_colmena => params[:id_colmena] }, :status => 200
	end

	def newsovercases
		@news = Case.poderjudicial_news_cases_details
	end

	def daily_mail_report
		now_date_time = DateTime.now
		destinatarios = [
			{
				:name => 'Felipe I. González G.',
				:email => 'felipe@coddea.com'
			},
			{
				:name => 'Ruben Ugarte',
				:email => 'rugarte@colmena.cl'
			},
			{
				:name => 'Fabiola Calderon',
				:email => 'fabiola.calderon@colmena.cl'
			}			
		]
		# Mail 1
		title1 = 'Nuevas causas '+now_date_time.strftime('%d-%m-%Y')
		@cases = Case.poderjudicial_new_cases
		msj1_txt = ""
		msj1_html = render_to_string partial: '/shared/mail/news', :locals => {:@title => title1}, :object => @cases, layout: false
		Case.send_email(
			title1,
			destinatarios,
			msj1_txt,
			msj1_html
		)
		# Mail 2
		title2 = 'Novedades '+now_date_time.strftime('%d-%m-%Y')
		@elements = Case.poderjudicial_news_cases_details
		msj2_html = render_to_string partial: '/shared/mail/developments', :locals => {:@title => title2}, :object => @elements, layout: false
		Case.send_email(
			title2,
			destinatarios,
			msj1_txt,
			msj2_html
		)
		render :json => { :status => true }, :status => 200
	end

	def daily_mail_report_fc
		now_date_time = DateTime.now
		destinatarios = [
			{
				:name => 'Felipe I. González G.',
				:email => 'felipe@coddea.com'
			}
		]
		# Mail 1
		title1 = 'Nuevas causas '+now_date_time.strftime('%d-%m-%Y')
		@cases = Case.poderjudicial_new_cases
		msj1_txt = ""
		msj1_html = render_to_string partial: '/shared/mail/news', :locals => {:@title => title1}, :object => @cases, layout: false
		Case.send_email(
			title1,
			destinatarios,
			msj1_txt,
			msj1_html
		)
		# Mail 2
		title2 = 'Novedades '+now_date_time.strftime('%d-%m-%Y')
		@elements = Case.poderjudicial_news_cases_details
		msj2_html = render_to_string partial: '/shared/mail/developments', :locals => {:@title => title2}, :object => @elements, layout: false
		Case.send_email(
			title2,
			destinatarios,
			msj1_txt,
			msj2_html
		)
	end

	def study_crawler
		result = StudyCase.study_crawler(params[:search])
		render :json => { :status => true, :study_crawler_search => params[:search], :study_crawler_result => result }, :status => 200
	end

	def proxy_test
		require 'tor-privoxy'
		agent = TorPrivoxy::Agent.new '127.0.0.1', '', 8118 => 9051
		render :json => { :status => true, :newip => agent.ip}, :status => 200
	end

	def crawler_test
		ble = Case.poderjudicial_crawler("COLMENA")
		render :json => { :status => true, :ble => ble}, :status => 200
	end

	def driver_test
		result = Case.test_driver_proxy
		if !result.nil? && !result[:value].blank?
			render :json => { :status => true, :result => result[:value]}, :status => 200
		else
			self.driver_test
		end
	end

	def proxy_socks5_test
		result = Case.test_http_sock5_proxy('http://corte.poderjudicial.cl/SITCORTEPORWEB/')
		if !result.nil? && !result.blank?
			render :json => { :status => true, :result => result}, :status => 200
		else
			self.driver_test
		end
	end

	def get_driver_test
		driver = Case.get_driver
		cookie = driver.manage.cookie_named("JSESSIONID")
		render :json => { :status => true, :result => cookie[:value]}, :status => 200
	end

	def get_driver_test_percent
		var = Array.new
		10.times do |i|
			driver = Case.get_driver
			cookie = driver.manage.cookie_named("JSESSIONID")
			var << cookie[:value]
			driver.close
		end
		render :json => { :status => true, :result => var}, :status => 200
	end

	def circuit_test
		require 'net/telnet'
		agenta = TorPrivoxy::Agent.new '127.0.0.1', '', 8118 => 9051
		oldip = agenta.ip
		localhost = Net::Telnet::new("Host" => "127.0.0.1", "Port" => "9051", "Timeout" => 10, "Prompt" => /250 OK\n/)
		localhost.cmd('AUTHENTICATE "colmena"') { |c| print c; throw "Cannot authenticate to Tor" if c != "250 OK\n" }
		localhost.cmd('signal NEWNYM') { |c| print c; throw "Cannot switch Tor to new route" if c != "250 OK\n" }
		localhost.close
		agentb = TorPrivoxy::Agent.new '127.0.0.1', '', 8118 => 9051
		newip = agentb.ip
		render :json => { :status => true, :oldip => oldip, :newip => newip}, :status => 200
	end
 
	def news_test
		Case.poderjudicial_news_crawler
		render :json => { :status => true }, :status => 200
	end

	def get_news_test
		now_date_time = DateTime.now
		cases = Case.where("updated_at > ?", now_date_time.beginning_of_day)
		render :json => { :status => true, :result => cases }, :status => 200
	end

	def get_with_chromedriver_test
		require 'selenium-webdriver'
		driver = Selenium::WebDriver.for(:chrome, args: ['headless'])
		driver.get('http://stackoverflow.com/')
		# driver.navigate.to "http://corte.poderjudicial.cl/SITCORTEPORWEB/"
		render :json => { :status => true, :result => driver.title }, :status => 200
	end

	def convert_fecha_ingreso_to_date
		cases = Case.all
		count = 0
		cases.each do |obj|
			count = count + 1
			obj.fecha_ingreso_como_fecha = Date.parse(obj.fecha_ingreso)
			obj.save
		end
		render :json => { :status => true, :quantity => count }, :status => 200
	end

	def regenerate_rol_rit
		cases = Case.all
		count = 0
		cases.each do |obj|
			count = count + 1
			rol_rit = obj.ningreso.split('-')
			obj.rol_rit = rol_rit[rol_rit.length - 2] + '-' + rol_rit[rol_rit.length - 1]
			obj.save
		end
		render :json => { :status => true, :quantity => count }, :status => 200
	end

	def generate_rol
		cases = Case.all
		count = 0
		cases.each do |obj|
			count = count + 1
			rol = obj.ningreso.split('-')
			obj.rol = rol[rol.length - 2]
			obj.save
		end
		render :json => { :status => true, :quantity => count }, :status => 200
	end

	def test_tor_rest
		result = Tor.request(url: 'http://ip.plusor.cn/', raw: false)
		require 'selenium-webdriver'
		driver = Selenium::WebDriver.for :phantomjs#, args: '--proxy=127.0.0.1:8118'
		driver.navigate.to "http://corte.poderjudicial.cl/SITCORTEPORWEB/"
		cookie = driver.manage.cookie_named("JSESSIONID")
		render :json => { :status => true, :result => result, :cookie => cookie }, :status => 200
	end

end
