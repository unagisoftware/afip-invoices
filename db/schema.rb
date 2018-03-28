# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_07_143040) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "afip_requests", force: :cascade do |t|
    t.integer "bill_type_id", null: false
    t.bigint "invoice_id_client", null: false
    t.integer "sale_point_id", null: false
    t.string "bill_number", null: false
    t.bigint "entity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_afip_requests_on_entity_id"
    t.index ["invoice_id_client"], name: "index_afip_requests_on_invoice_id_client"
  end

  create_table "associated_invoices", force: :cascade do |t|
    t.string "receipt", null: false
    t.date "emission_date", null: false
    t.integer "bill_type_id", null: false
    t.bigint "invoice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_associated_invoices_on_invoice_id"
  end

  create_table "entities", force: :cascade do |t|
    t.text "certificate"
    t.text "private_key"
    t.text "csr"
    t.string "cuit"
    t.string "name"
    t.string "business_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auth_token"
    t.string "logo"
    t.string "condition_against_iva"
    t.date "activity_start_date"
    t.string "comertial_address"
    t.string "iibb"
    t.index ["business_name"], name: "index_entities_on_business_name", unique: true
    t.index ["cuit"], name: "index_entities_on_cuit", unique: true
  end

  create_table "invoice_items", force: :cascade do |t|
    t.string "code"
    t.string "description", null: false
    t.float "quantity", default: 1.0, null: false
    t.float "unit_price", default: 0.0, null: false
    t.float "bonus_percentage", default: 0.0, null: false
    t.string "metric_unit", default: "unidades"
    t.bigint "invoice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "iva_aliquot_id", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "entity_id"
    t.date "emission_date", null: false
    t.string "authorization_code", null: false
    t.string "receipt", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bill_type_id", null: false
    t.string "token", null: false
    t.string "logo_url"
    t.text "note"
    t.jsonb "recipient"
    t.string "cbu"
    t.string "alias"
    t.index ["bill_type_id", "receipt"], name: "index_invoices_on_bill_type_id_and_receipt"
    t.index ["entity_id"], name: "index_invoices_on_entity_id"
    t.index ["token"], name: "index_invoices_on_token", unique: true
  end

  add_foreign_key "afip_requests", "entities"
  add_foreign_key "associated_invoices", "invoices"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoices", "entities"
end
