class AddIdColmenaToCase < ActiveRecord::Migration[5.0]
	def change
		add_column :cases, :id_colmena, :integer, default: nil, null: true, :after => :estado_colmena_situacion
	end
end
