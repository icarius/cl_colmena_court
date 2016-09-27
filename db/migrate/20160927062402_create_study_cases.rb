class CreateStudyCases < ActiveRecord::Migration[5.0]
	def change
		create_table :study_cases do |t|
			t.string :rol_rit
			t.string :ruc
			t.string :ningreso
			t.string :corte
			t.string :fecha_ingreso
			t.string :rut_sujeto
			t.string :nombre_sujeto
			t.string :rut_abogado
			t.string :nombre_abodago
			t.string :estado_procesal
			t.string :link_caso_detalle
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
