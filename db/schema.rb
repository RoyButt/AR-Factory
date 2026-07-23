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

ActiveRecord::Schema[7.0].define(version: 2026_07_23_090000) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "card_addons", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "cost_card_id", null: false
    t.string "target", default: "final"
    t.string "label"
    t.decimal "amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cost_card_id"], name: "index_card_addons_on_cost_card_id"
  end

  create_table "claim_colors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "khatta_emb_id"
    t.string "kind"
    t.bigint "fabric_lot_color_id"
    t.string "color_name"
    t.integer "suits", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["khatta_emb_id", "kind"], name: "index_claim_colors_on_khatta_emb_id_and_kind"
    t.index ["khatta_emb_id"], name: "index_claim_colors_on_khatta_emb_id"
  end

  create_table "cost_cards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code"
    t.decimal "fabric_rate", precision: 10, scale: 2, default: "0.0"
    t.decimal "fabric_multiplier", precision: 6, scale: 2, default: "4.0"
    t.decimal "cmt", precision: 10, scale: 2, default: "0.0"
    t.decimal "cut_work", precision: 10, scale: 2, default: "0.0"
    t.decimal "hand_made", precision: 10, scale: 2, default: "0.0"
    t.decimal "cm", precision: 10, scale: 2, default: "0.0"
    t.decimal "lass", precision: 10, scale: 2, default: "0.0"
    t.date "card_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "emb_addon", precision: 10, scale: 2, default: "25.0"
    t.decimal "final_addon", precision: 10, scale: 2, default: "100.0"
  end

  create_table "cost_lines", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "cost_card_id", null: false
    t.string "name"
    t.decimal "amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cost_card_id"], name: "index_cost_lines_on_cost_card_id"
  end

  create_table "cutwork_parties", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "contact"
    t.string "email"
    t.string "address"
    t.string "city"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cutwork_payments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "cutwork_party_id"
    t.decimal "amount", precision: 12, scale: 2
    t.date "paid_on"
    t.string "method_detail"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cutwork_party_id"], name: "index_cutwork_payments_on_cutwork_party_id"
  end

  create_table "design_variants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "design_id", null: false
    t.string "size"
    t.decimal "repeats_per_color", precision: 8, scale: 2, default: "0.0"
    t.decimal "trousers", precision: 8, scale: 2, default: "0.0"
    t.decimal "back", precision: 8, scale: 2, default: "0.0"
    t.decimal "bazoo", precision: 8, scale: 2, default: "0.0"
    t.decimal "kali", precision: 8, scale: 2, default: "0.0"
    t.decimal "falas", precision: 8, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_id"], name: "index_design_variants_on_design_id"
  end

  create_table "designs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code"
    t.string "category"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emb_files", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "cost_card_id", null: false
    t.integer "sr"
    t.string "file_name"
    t.integer "stitch", default: 0
    t.decimal "heads", precision: 6, scale: 2, default: "0.0"
    t.decimal "reapts", precision: 6, scale: 2, default: "1.0"
    t.decimal "rate", precision: 6, scale: 3, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cost_card_id"], name: "index_emb_files_on_cost_card_id"
  end

  create_table "emb_parties", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "contact"
    t.string "email"
    t.string "address"
    t.string "city"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fabric_lot_colors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "fabric_lot_id", null: false
    t.string "name"
    t.decimal "received_gazana", precision: 10, scale: 2, default: "0.0"
    t.decimal "wastage", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hex"
    t.index ["fabric_lot_id"], name: "index_fabric_lot_colors_on_fabric_lot_id"
  end

  create_table "fabric_lot_lines", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "fabric_lot_id", null: false
    t.bigint "fabric_lot_color_id"
    t.bigint "design_variant_id"
    t.string "contractor"
    t.integer "suits", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "head_size"
    t.index ["design_variant_id"], name: "index_fabric_lot_lines_on_design_variant_id"
    t.index ["fabric_lot_color_id"], name: "index_fabric_lot_lines_on_fabric_lot_color_id"
    t.index ["fabric_lot_id"], name: "index_fabric_lot_lines_on_fabric_lot_id"
  end

  create_table "fabric_lots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "laat_number"
    t.string "line_type"
    t.date "lot_date"
    t.integer "total_suit"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fabric_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.integer "year"
    t.decimal "rate", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "handmade_parties", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "contact"
    t.string "email"
    t.string "address"
    t.string "city"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "handmade_rate", precision: 10, scale: 2, default: "0.0", null: false
  end

  create_table "handmade_passes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "handmade_party_id"
    t.bigint "production_progress_id"
    t.string "design_code"
    t.integer "laat"
    t.integer "suits"
    t.decimal "rate", precision: 10, scale: 2, default: "0.0"
    t.decimal "adjustment", precision: 10, scale: 2, default: "0.0"
    t.date "pass_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["handmade_party_id"], name: "index_handmade_passes_on_handmade_party_id"
    t.index ["production_progress_id"], name: "index_handmade_passes_on_production_progress_id"
  end

  create_table "handmade_payments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "handmade_party_id"
    t.decimal "amount", precision: 12, scale: 2
    t.date "paid_on"
    t.string "method_detail"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["handmade_party_id"], name: "index_handmade_payments_on_handmade_party_id"
  end

  create_table "khatta_deliveries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "khatta_emb_id", null: false
    t.integer "suits", default: 0
    t.date "delivered_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "allowed_at"
    t.index ["khatta_emb_id"], name: "index_khatta_deliveries_on_khatta_emb_id"
  end

  create_table "khatta_embs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "contractor"
    t.string "design_code"
    t.integer "suits", default: 0
    t.date "returned_on"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "suits_sent", default: 0
    t.bigint "fabric_lot_id"
    t.decimal "rate", precision: 10, scale: 2
    t.integer "claim_suits", default: 0
    t.decimal "bill_override", precision: 12, scale: 2
    t.decimal "claim_override", precision: 12, scale: 2
    t.integer "stitch_claim_suits", default: 0
    t.index ["fabric_lot_id"], name: "index_khatta_embs_on_fabric_lot_id"
  end

  create_table "khatta_payments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "contractor", null: false
    t.decimal "amount", precision: 12, scale: 2, default: "0.0"
    t.date "paid_on"
    t.string "method_detail"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contractor"], name: "index_khatta_payments_on_contractor"
  end

  create_table "line_color_usages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "fabric_lot_line_id", null: false
    t.bigint "fabric_lot_color_id", null: false
    t.decimal "emb", precision: 10, scale: 2
    t.decimal "backup", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "factor", precision: 4, scale: 2, default: "1.0"
    t.decimal "backup_factor", precision: 4, scale: 2, default: "1.0"
    t.index ["fabric_lot_color_id"], name: "index_line_color_usages_on_fabric_lot_color_id"
    t.index ["fabric_lot_line_id"], name: "index_line_color_usages_on_fabric_lot_line_id"
  end

  create_table "lot_adjustments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "fabric_lot_id", null: false
    t.bigint "fabric_lot_color_id"
    t.string "contractor"
    t.string "design"
    t.decimal "gazana", precision: 10, scale: 2, default: "0.0"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "date"
    t.index ["fabric_lot_color_id"], name: "index_lot_adjustments_on_fabric_lot_color_id"
    t.index ["fabric_lot_id"], name: "index_lot_adjustments_on_fabric_lot_id"
  end

  create_table "lot_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "production_lot_id", null: false
    t.string "stage"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["production_lot_id"], name: "index_lot_attachments_on_production_lot_id"
  end

  create_table "lot_patterns", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "fabric_lot_id", null: false
    t.string "name"
    t.json "data"
    t.boolean "finalized", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fabric_lot_id"], name: "index_lot_patterns_on_fabric_lot_id"
  end

  create_table "party_prices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "cost_card_id", null: false
    t.string "party_name"
    t.string "pricing_mode", default: "markup_pct"
    t.decimal "value", precision: 10, scale: 2, default: "0.0"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cost_card_id"], name: "index_party_prices_on_cost_card_id"
  end

  create_table "production_claims", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "production_progress_id"
    t.bigint "handmade_pass_id"
    t.bigint "production_party_id"
    t.string "design_code"
    t.integer "laat"
    t.decimal "rate", precision: 12, scale: 2, default: "0.0"
    t.integer "suits", default: 0
    t.decimal "amount", precision: 12, scale: 2, default: "0.0"
    t.json "colors"
    t.date "claimed_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["production_party_id"], name: "index_production_claims_on_production_party_id"
    t.index ["production_progress_id"], name: "index_production_claims_on_production_progress_id"
  end

  create_table "production_lots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "emb_name"
    t.string "design"
    t.string "laat_number"
    t.integer "total_suit"
    t.date "production_date"
    t.date "cutwork_sent_date"
    t.boolean "cutwork_paid", default: false, null: false
    t.date "cutwork_paid_date"
    t.date "overlock_sent_date"
    t.boolean "overlock_paid", default: false, null: false
    t.date "overlock_paid_date"
    t.boolean "handmade_paid", default: false, null: false
    t.date "handmade_paid_date"
    t.date "handmade_return_date"
    t.date "press_date"
    t.date "out_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cutwork_sent_qty"
    t.integer "cutwork_received_qty"
    t.integer "overlock_sent_qty"
    t.integer "overlock_received_qty"
    t.integer "handmade_sent_qty"
    t.integer "handmade_received_qty"
    t.date "emb_sent_date"
    t.integer "emb_sent_qty"
    t.date "emb_received_date"
    t.integer "emb_received_qty"
    t.boolean "emb_paid", default: false, null: false
    t.date "emb_paid_date"
  end

  create_table "production_parties", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "contact"
    t.text "notes"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "family_contact"
  end

  create_table "production_progresses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "production_sheet_id"
    t.bigint "fabric_lot_id"
    t.string "design_code"
    t.integer "laat"
    t.integer "suits"
    t.string "stage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cutwork_party_id"
    t.decimal "adjustment", precision: 10, scale: 2, default: "0.0", null: false
    t.index ["cutwork_party_id"], name: "index_production_progresses_on_cutwork_party_id"
    t.index ["fabric_lot_id"], name: "index_production_progresses_on_fabric_lot_id"
    t.index ["production_sheet_id"], name: "index_production_progresses_on_production_sheet_id"
  end

  create_table "production_sheets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "sheet_date"
    t.string "day"
    t.json "rows"
    t.json "values"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "hidden_cols"
    t.boolean "prepared", default: false
    t.json "targets"
    t.date "stitch_date"
    t.datetime "completed_at"
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "label"
    t.decimal "value", precision: 12, scale: 4, default: "0.0"
    t.string "grouping"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "stitching_cost_cards", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "design_code", null: false
    t.decimal "shirt_stitch_rate", precision: 10, scale: 2, default: "0.0"
    t.decimal "trouser_stitch_rate", precision: 10, scale: 2, default: "0.0"
    t.decimal "shirt_overlock", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_code"], name: "index_stitching_cost_cards_on_design_code", unique: true
  end

  create_table "stitching_earnings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "production_party_id"
    t.bigint "production_sheet_id"
    t.string "design_code"
    t.integer "laat"
    t.integer "suits"
    t.decimal "rate", precision: 10, scale: 2
    t.decimal "amount", precision: 12, scale: 2
    t.date "earned_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["production_party_id"], name: "index_stitching_earnings_on_production_party_id"
    t.index ["production_sheet_id"], name: "index_stitching_earnings_on_production_sheet_id"
  end

  create_table "stitching_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "khatta_delivery_id"
    t.bigint "production_party_id"
    t.integer "suits"
    t.string "design"
    t.integer "laat"
    t.date "sent_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "supervisor", default: "Supervisor"
    t.date "start_on"
    t.bigint "khatta_emb_id"
    t.index ["khatta_delivery_id"], name: "index_stitching_jobs_on_khatta_delivery_id"
    t.index ["khatta_emb_id"], name: "index_stitching_jobs_on_khatta_emb_id"
    t.index ["production_party_id"], name: "index_stitching_jobs_on_production_party_id"
  end

  create_table "stitching_payments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "production_party_id"
    t.decimal "amount", precision: 12, scale: 2
    t.date "paid_on"
    t.string "method_detail"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "advance", default: false, null: false
    t.index ["production_party_id"], name: "index_stitching_payments_on_production_party_id"
  end

  create_table "stock_entries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "stock_date"
    t.string "source"
    t.string "product_name"
    t.decimal "quantity", precision: 12, scale: 2, default: "0.0"
    t.string "unit"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "viewer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "view_only", default: false, null: false
    t.text "allowed_sections"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "variant_components", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "design_variant_id", null: false
    t.string "name"
    t.decimal "value", precision: 8, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["design_variant_id"], name: "index_variant_components_on_design_variant_id"
  end

  create_table "workers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.decimal "piece_rate", precision: 8, scale: 2, default: "0.0"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "card_addons", "cost_cards"
  add_foreign_key "cost_lines", "cost_cards"
  add_foreign_key "cutwork_payments", "cutwork_parties"
  add_foreign_key "design_variants", "designs"
  add_foreign_key "emb_files", "cost_cards"
  add_foreign_key "fabric_lot_colors", "fabric_lots"
  add_foreign_key "fabric_lot_lines", "design_variants"
  add_foreign_key "fabric_lot_lines", "fabric_lot_colors"
  add_foreign_key "fabric_lot_lines", "fabric_lots"
  add_foreign_key "handmade_passes", "handmade_parties"
  add_foreign_key "handmade_passes", "production_progresses"
  add_foreign_key "handmade_payments", "handmade_parties"
  add_foreign_key "khatta_deliveries", "khatta_embs"
  add_foreign_key "khatta_embs", "fabric_lots"
  add_foreign_key "line_color_usages", "fabric_lot_colors"
  add_foreign_key "line_color_usages", "fabric_lot_lines"
  add_foreign_key "lot_adjustments", "fabric_lot_colors"
  add_foreign_key "lot_adjustments", "fabric_lots"
  add_foreign_key "lot_attachments", "production_lots"
  add_foreign_key "lot_patterns", "fabric_lots"
  add_foreign_key "party_prices", "cost_cards"
  add_foreign_key "production_progresses", "cutwork_parties"
  add_foreign_key "production_progresses", "fabric_lots"
  add_foreign_key "production_progresses", "production_sheets"
  add_foreign_key "stitching_earnings", "production_parties"
  add_foreign_key "stitching_earnings", "production_sheets"
  add_foreign_key "stitching_jobs", "khatta_deliveries"
  add_foreign_key "stitching_jobs", "khatta_embs"
  add_foreign_key "stitching_jobs", "production_parties"
  add_foreign_key "stitching_payments", "production_parties"
  add_foreign_key "variant_components", "design_variants"
end
