class CreateCaseSolves < ActiveRecord::Migration[5.0]
	def change
		create_table :case_solves do |t|
			t.integer :case_id
			t.string :doc
			t.string :fecha_ingreso
			t.string :tipo_escrito
			t.string :solicitante
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
