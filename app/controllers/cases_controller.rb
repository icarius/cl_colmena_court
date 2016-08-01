class CasesController < ApplicationController

	def welcome
		render :json => { :status => true, :message => "Colmena golden cross 'Colmena court'." }, :status => 200
	end

	def index
		@cases = Case.search(params[:term], params[:page])
	end

	def show
		@case = Case.find_by_id(params[:id])
	end

	def new
		@case = Case.new
	end

	def create
		@case = Case.new(cases_params)
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
		if @case.update_attributes(cases_params)
			flash[:success] = "El caso fue modificado!"
			render 'edit'
		end
	end

	def destroy
		Case.find(params[:id]).destroy
		flash[:success] = "El caso fue eliminado"
		render 'index'
	end

	private

	def cases_params
		params.require(:case).permit(
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
