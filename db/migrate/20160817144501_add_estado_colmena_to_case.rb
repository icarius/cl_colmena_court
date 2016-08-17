class AddEstadoColmenaToCase < ActiveRecord::Migration[5.0]
	def change
		add_column :cases, :estado_colmena, :string, default: 'ingresado', :after => :estado_procesal
	end
end
