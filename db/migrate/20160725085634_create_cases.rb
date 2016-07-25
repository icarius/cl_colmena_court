class CreateCases < ActiveRecord::Migration[5.0]
	def change
		create_table :cases do |t|
			t.string :rol, null: false
			t.date :date, null: true
			t.string :caption, null: false
			t.string :court, null: false
			t.timestamps null: false
			t.boolean :status, default: 1, null: true
		end
	end
end
