class CreateCases < ActiveRecord::Migration[5.0]
	def change
		create_table :cases do |t|
			t.string :entry_number, null: false
			t.date :entry_date, null: true
			t.string :location, null: false
			t.date :location_date, null: true
			t.string :court, null: false
			t.string :caption, null: false
			t.string :public_detail_url, null: false
			t.timestamps null: false
			t.boolean :status, default: 1, null: true
		end
	end
end
