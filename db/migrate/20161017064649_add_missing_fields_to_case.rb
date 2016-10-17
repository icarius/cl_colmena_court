class AddMissingFieldsToCase < ActiveRecord::Migration[5.0]
	def change
		add_column :cases, :tipo_causa, :string, default: nil, null: true, :after => :ningreso
		add_column :cases, :correlativo, :string, default: nil, null: true, :after => :tipo_causa
		add_column :cases, :ano, :string, default: nil, null: true, :after => :correlativo
		change_column :cases, :corte, :string, default: nil, null: true, :after => :ano
	end
end
