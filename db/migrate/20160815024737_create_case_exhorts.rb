class CreateCaseExhorts < ActiveRecord::Migration[5.0]
	def change
		create_table :case_exhorts do |t|
			t.integer :case_id
			t.string :rit_origen
			t.string :tipo_exhorto
			t.string :rit_destino
			t.string :fecha_ordena_exhorto
			t.string :fecha_ingreso_exhorto
			t.string :tribunal_destino
			t.string :estado_exhorto
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
