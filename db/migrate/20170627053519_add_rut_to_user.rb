class AddRutToUser < ActiveRecord::Migration[5.0]
	def change
		add_column :users, :rut, :string, default: nil, null: true, :after => :email
	end
end
