class RemoveEstadoColmenaProcesalfromCase < ActiveRecord::Migration[5.0]
	def change
		if column_exists? :cases, :estado_colmena_procesal
			remove_column :cases, :estado_colmena_procesal
		end
	end
end
