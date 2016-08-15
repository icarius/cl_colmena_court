class CreateCases < ActiveRecord::Migration[5.0]
	def change
		create_table :cases do |t|
			t.string :rol
			t.string :rit
			t.string :ruc
			t.string :ningreso
			t.string :ubicacion
			t.string :corte
			t.string :caratulado
			t.string :recurso
			t.string :fecha_ingreso
			t.string :fecha_ubicacion
			t.string :estado_recurso
			t.string :estado_procesal
			t.string :link_caso_detalle
			t.string :link_caso_txt
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
