class CreateCases < ActiveRecord::Migration[5.0]
	def change
		create_table :cases do |t|
			t.string :rol
			t.string :fecha
			t.string :caratulado
			t.string :tribunal
			t.string :est_adm
			t.string :proc
			t.string :ubicacion
			t.string :etapa
			t.string :est_proc
			t.string :link_txt_exhorto
			t.string :link_level_1
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
