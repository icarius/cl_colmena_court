# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171117041331) do

  create_table "case_histories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "case_id",                            null: false
    t.string   "folio"
    t.string   "ano"
    t.string   "link_doc"
    t.string   "sala"
    t.string   "tramite"
    t.string   "descripcion_tramite"
    t.string   "fecha_tramite"
    t.string   "estado"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "status",              default: true
  end

  create_table "case_litigants", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer  "case_id",                     null: false
    t.string   "sujeto"
    t.string   "rut"
    t.string   "persona"
    t.string   "razon_social"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "status",       default: true
  end

  create_table "cases", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "rol_rit"
    t.string   "ruc"
    t.string   "rol"
    t.string   "ningreso"
    t.string   "tipo_causa"
    t.string   "correlativo"
    t.string   "ano"
    t.string   "corte"
    t.string   "ubicacion"
    t.string   "caratulado"
    t.string   "recurso"
    t.string   "fecha_ingreso"
    t.date     "fecha_ingreso_como_fecha"
    t.string   "fecha_ubicacion"
    t.string   "estado_recurso"
    t.string   "estado_procesal"
    t.string   "estado_colmena",           default: "ingresado"
    t.string   "estado_colmena_situacion"
    t.integer  "id_colmena"
    t.string   "link_caso_detalle"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "status",                   default: true
  end

  create_table "study_cases", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "rol"
    t.string   "rit"
    t.string   "ruc"
    t.string   "ningreso"
    t.string   "tipo_causa"
    t.string   "correlativo"
    t.string   "ano"
    t.string   "corte"
    t.string   "fecha_ingreso"
    t.string   "recurrente_nombre_1"
    t.string   "recurrente_rut_1"
    t.string   "recurrente_nombre_2"
    t.string   "recurrente_rut_2"
    t.string   "recurrente_nombre_3"
    t.string   "recurrente_rut_3"
    t.string   "recurrente_nombre_4"
    t.string   "recurrente_rut_4"
    t.string   "abrecurrente_nombre_1"
    t.string   "abrecurrente_rut_1"
    t.string   "abrecurrente_nombre_2"
    t.string   "abrecurrente_rut_2"
    t.string   "abrecurrente_nombre_3"
    t.string   "abrecurrente_rut_3"
    t.string   "abrecurrente_nombre_4"
    t.string   "abrecurrente_rut_4"
    t.string   "recurrido_nombre"
    t.string   "recurrido_rut"
    t.string   "estado_procesal"
    t.string   "link_caso_detalle"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "status",                default: true
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string   "email",                  default: "", null: false
    t.string   "rut"
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
