class AddEstadoColmenaSituacionToCase < ActiveRecord::Migration[5.0]
	def change
		add_column :cases, :estado_colmena_situacion, :string, default: nil, null: true, :after => :estado_colmena
	end
end
