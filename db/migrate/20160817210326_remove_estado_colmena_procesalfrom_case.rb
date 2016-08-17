class RemoveEstadoColmenaProcesalfromCase < ActiveRecord::Migration[5.0]
	def change
		remove_column :cases, :estado_colmena_procesal
	end
end
