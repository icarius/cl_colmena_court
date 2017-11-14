class AddFingresoAsADate < ActiveRecord::Migration[5.0]
	def change
		add_column :cases, :fecha_ingreso_como_fecha, :date, default: nil, null: true, :after => :fecha_ingreso
	end
end
