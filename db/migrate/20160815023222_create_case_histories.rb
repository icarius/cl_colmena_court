class CreateCaseHistories < ActiveRecord::Migration[5.0]
	def change
		create_table :case_histories do |t|
			t.integer :case_id, :null => false
			t.string :folio
			t.string :ano
			t.string :link_doc
			t.string :sala
			t.string :tramite
			t.string :descripcion_tramite
			t.string :fecha_tramite
			t.string :estado
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
