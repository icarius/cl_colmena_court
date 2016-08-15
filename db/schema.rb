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

ActiveRecord::Schema.define(version: 20160815024737) do

  create_table "case_exhorts", force: :cascade do |t|
    t.integer  "case_id"
    t.string   "rit_origen"
    t.string   "tipo_exhorto"
    t.string   "rit_destino"
    t.string   "fecha_ordena_exhorto"
    t.string   "fecha_ingreso_exhorto"
    t.string   "tribunal_destino"
    t.string   "estado_exhorto"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "status",                default: true
  end

  create_table "case_histories", force: :cascade do |t|
    t.integer  "case_id"
    t.string   "folio"
    t.string   "link_doc"
    t.string   "etapa"
    t.string   "tramite"
    t.string   "descripcion_tramite"
    t.string   "fecha_tramite"
    t.string   "foja"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "status",              default: true
  end

  create_table "case_litigants", force: :cascade do |t|
    t.integer  "case_id"
    t.string   "participante"
    t.string   "rut"
    t.string   "persona"
    t.string   "razon_social"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "status",       default: true
  end

  create_table "case_notifications", force: :cascade do |t|
    t.integer  "case_id"
    t.string   "estado_notificacion"
    t.string   "rol"
    t.string   "ruc"
    t.string   "fecha_tramite"
    t.string   "tipo_part"
    t.string   "nombre"
    t.string   "tramite"
    t.string   "obs_fallida"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "status",              default: true
  end

  create_table "case_solves", force: :cascade do |t|
    t.integer  "case_id"
    t.string   "doc"
    t.string   "fecha_ingreso"
    t.string   "tipo_escrito"
    t.string   "solicitante"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "status",        default: true
  end

  create_table "cases", force: :cascade do |t|
    t.string   "rol"
    t.string   "fecha"
    t.string   "caratulado"
    t.string   "tribunal"
    t.string   "est_adm"
    t.string   "proc"
    t.string   "ubicacion"
    t.string   "etapa"
    t.string   "est_proc"
    t.string   "link_txt_exhorto"
    t.string   "link_level_1"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "status",           default: true
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
