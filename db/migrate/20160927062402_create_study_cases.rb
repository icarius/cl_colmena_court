class CreateStudyCases < ActiveRecord::Migration[5.0]
	def change
		create_table :study_cases do |t|
			t.string :rol
			t.string :rit
			t.string :ruc
			t.string :ningreso
			t.string :tipo_causa
			t.string :correlativo
			t.string :ano
			t.string :corte
			t.string :fecha_ingreso
			t.string :recurrente_nombre_1
			t.string :recurrente_rut_1
			t.string :recurrente_nombre_2
			t.string :recurrente_rut_2
			t.string :recurrente_nombre_3
			t.string :recurrente_rut_3
			t.string :recurrente_nombre_4
			t.string :recurrente_rut_4
			t.string :abrecurrente_nombre_1
			t.string :abrecurrente_rut_1
			t.string :abrecurrente_nombre_2
			t.string :abrecurrente_rut_2
			t.string :abrecurrente_nombre_3
			t.string :abrecurrente_rut_3
			t.string :abrecurrente_nombre_4
			t.string :abrecurrente_rut_4
			t.string :recurrido_nombre
			t.string :recurrido_rut			
			t.string :estado_procesal
			t.string :link_caso_detalle
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
