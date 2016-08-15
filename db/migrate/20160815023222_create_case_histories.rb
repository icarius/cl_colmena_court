class CreateCaseHistories < ActiveRecord::Migration[5.0]
	def change
		create_table :case_histories do |t|
			t.integer :case_id
			t.string :folio
			t.string :link_doc
			t.string :etapa
			t.string :tramite
			t.string :descripcion_tramite
			t.string :fecha_tramite
			t.string :foja
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
