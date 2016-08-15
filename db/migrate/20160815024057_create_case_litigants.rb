class CreateCaseLitigants < ActiveRecord::Migration[5.0]
	def change
		create_table :case_litigants do |t|
			t.integer :case_id
			t.string :participante
			t.string :rut
			t.string :persona
			t.string :razon_social
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
