class CaseController < ApplicationController

	def welcome
		render :json => { :status => true, :message => "Colmena golden cross 'Colmena court'." }, :status => 200
	end

	def index
		@cases = Case.search(params[:term], params[:page])
	end

	def show
		@cases = Case.find_by_id(params[:id])
	end

	def new
		@cases = Case.new
	end

	def create
		@case = Case.new(case_params)
		# Se guarda y se actua segun resultado
		if @case.save
			flash[:success] = "El caso fue creado de forma exitosa!"
			render 'edit'
		else
			render 'new'
		end	
	end

	def edit
		@case = Case.find_by_id(params[:id])
	end

	def update
		@case = Case.find_by_id(params[:id])
		# Guardamos y actuamos segun corresponda
		if @case.update_attributes(case_params)
			flash[:success] = "El caso fue modificado!"
			render 'edit'
		else
			render 'edit'
		end
	end

	def destroy
		Case.find(params[:id]).destroy
		flash[:success] = "El caso fue eliminado"
		render 'index'
	end

	private

	def case_params
		params.require(:cases).permit(
			:entry_number,
			:entry_date,
			:location,
			:location_date,
			:court,
			:caption,
			:public_detail_url,
			:created_at,
			:updated_at,
			:status
		)
	end

end
