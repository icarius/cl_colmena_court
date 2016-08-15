class CreateCaseNotifications < ActiveRecord::Migration[5.0]
	def change
		create_table :case_notifications do |t|
			t.integer :case_id
			t.string :estado_notificacion
			t.string :rol
			t.string :ruc
			t.string :fecha_tramite
			t.string :tipo_part
			t.string :nombre
			t.string :tramite
			t.string :obs_fallida
			t.timestamps
			t.boolean :status, default: 1
		end
	end
end
