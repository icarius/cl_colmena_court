class AddRolToCase < ActiveRecord::Migration[5.0]
	def change
		add_column :cases, :rol, :string, default: nil, null: true, :after => :ruc
	end
end
