# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20190523064732) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.text     "body"
    t.integer  "question_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree

  create_table "avatars", force: :cascade do |t|
    t.string   "image"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bountytypes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bountytypes_lessons", force: :cascade do |t|
    t.integer "category_id"
    t.integer "lesson_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_lessons", force: :cascade do |t|
    t.integer "category_id"
    t.integer "lesson_id"
  end

  create_table "chatimages", force: :cascade do |t|
    t.string   "image"
    t.integer  "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "timezone_offset"
    t.integer  "read_status"
    t.integer  "message_notification_job_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deliveryslots", force: :cascade do |t|
    t.date     "date"
    t.integer  "timeslot_id"
    t.integer  "order_id"
    t.integer  "taken"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "deliveryslots", ["order_id"], name: "index_deliveryslots_on_order_id", using: :btree
  add_index "deliveryslots", ["timeslot_id"], name: "index_deliveryslots_on_timeslot_id", using: :btree

  create_table "disputes", force: :cascade do |t|
    t.text     "body"
    t.integer  "lesson_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "disputes", ["lesson_id"], name: "index_disputes_on_lesson_id", using: :btree
  add_index "disputes", ["user_id"], name: "index_disputes_on_user_id", using: :btree

  create_table "emails", force: :cascade do |t|
    t.string   "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guests", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "contact_number"
    t.string   "email"
    t.integer  "rsvp_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "child_index"
  end

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.string   "brand"
    t.string   "item_photo"
    t.string   "description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "tag"
    t.decimal  "price_sg",    precision: 8, scale: 2
    t.decimal  "price_my",    precision: 8, scale: 2
    t.integer  "status"
  end

  create_table "lessons", force: :cascade do |t|
    t.string   "title"
    t.string   "address_postal"
    t.string   "tag"
    t.integer  "organizer_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address_street"
    t.string   "address_unit"
    t.string   "address_country"
    t.string   "address_city"
    t.string   "address_name"
    t.integer  "token",                     limit: 8
    t.integer  "timezone_offset"
    t.string   "job_photo"
    t.date     "date_completed"
    t.datetime "datetime_completed"
    t.date     "date_awarded"
    t.datetime "datetime_awarded"
    t.string   "address_block_number"
    t.string   "contact_no"
    t.integer  "awardee_id"
    t.datetime "job_completed_datetime"
    t.datetime "job_verified_datetime"
    t.decimal  "bounty",                              precision: 8, scale: 2
    t.text     "description"
    t.datetime "bounty_received_datetime"
    t.datetime "owner_cancel_job"
    t.datetime "solver_cancel_job"
    t.boolean  "owner_agree_cancel"
    t.boolean  "solver_agree_cancel"
    t.text     "dispute_details"
    t.integer  "refund_bounty_tx_id"
    t.integer  "owner_auto_refund_job_id"
    t.integer  "solver_auto_refund_job_id"
    t.string   "bounty_transferred_id"
    t.integer  "bounty_type"
    t.decimal  "deposit",                             precision: 8, scale: 2
    t.integer  "bounty_received_method"
    t.integer  "pending_awardee_id"
    t.datetime "raise_a_dispute_sponsor"
    t.datetime "raise_a_dispute_hunter"
  end

  create_table "locations", force: :cascade do |t|
    t.string   "block_no"
    t.string   "road_name"
    t.string   "building"
    t.string   "address"
    t.string   "postal"
    t.float    "lat"
    t.float    "lng"
    t.string   "unit_no"
    t.string   "country"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "lesson_id"
    t.integer  "child_index"
    t.string   "name"
    t.integer  "order_id"
  end

  add_index "locations", ["lesson_id"], name: "index_locations_on_lesson_id", using: :btree
  add_index "locations", ["order_id"], name: "index_locations_on_order_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.text     "body"
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "sent_at_timezone"
    t.string   "photo"
  end

  add_index "messages", ["conversation_id"], name: "index_messages_on_conversation_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "orderitems", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "order_id"
    t.integer  "user_id"
    t.integer  "quantity"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "orderitems", ["item_id"], name: "index_orderitems_on_item_id", using: :btree
  add_index "orderitems", ["order_id"], name: "index_orderitems_on_order_id", using: :btree
  add_index "orderitems", ["user_id"], name: "index_orderitems_on_user_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.datetime "deliver_datetime"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "user_id"
    t.datetime "payment_received_datetime"
    t.string   "payment_transferred_id"
    t.integer  "payment_method"
    t.decimal  "amount",                    precision: 8, scale: 2
    t.integer  "status"
    t.string   "name"
    t.string   "contact_no"
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.string   "image"
    t.integer  "lesson_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.text     "body"
    t.integer  "lesson_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text     "body"
    t.integer  "user_id"
    t.integer  "lesson_id"
    t.integer  "rating_owner"
    t.integer  "rating_solver"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "reviewer_id"
  end

  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "rsvps", force: :cascade do |t|
    t.integer  "attendee_id"
    t.integer  "attended_lesson_id"
    t.integer  "queue_number"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "timeslots"
    t.string   "endpoint"
    t.string   "auth"
    t.string   "p256dh"
    t.integer  "email_job_id"
    t.integer  "push_job_id"
    t.datetime "bid_withdraw"
    t.decimal  "bid",                precision: 8, scale: 2
    t.decimal  "deposit",            precision: 8, scale: 2
  end

  add_index "rsvps", ["attended_lesson_id"], name: "index_rsvps_on_attended_lesson_id", using: :btree
  add_index "rsvps", ["attendee_id"], name: "index_rsvps_on_attendee_id", using: :btree

  create_table "timeslots", force: :cascade do |t|
    t.string   "slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.string   "cash_out_id"
    t.integer  "transaction_type"
    t.integer  "wallet_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.decimal  "amount",           precision: 8, scale: 2
    t.integer  "lesson_id"
    t.string   "bank_tx_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                             default: "",    null: false
    t.string   "encrypted_password",                                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.boolean  "admin",                                             default: false
    t.string   "username"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "contact_number"
    t.string   "company"
    t.string   "website"
    t.string   "address"
    t.string   "address_2"
    t.string   "city"
    t.string   "country"
    t.string   "postal_code"
    t.string   "gender"
    t.date     "birth_date"
    t.integer  "age"
    t.string   "profile_pic"
    t.boolean  "email_confirmed"
    t.string   "confirm_token"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "ongoing_problems_owner"
    t.string   "completed_problems_owner"
    t.string   "ongoing_problems_solver"
    t.string   "completed_problems_solver"
    t.decimal  "rating_owner",              precision: 3, scale: 2, default: 0.0
    t.decimal  "rating_solver",             precision: 3, scale: 2, default: 0.0
    t.string   "endpoint"
    t.string   "p256dh"
    t.string   "auth"
    t.integer  "owner_cancel"
    t.integer  "solver_cancel"
    t.string   "country_code_contact"
    t.integer  "account_status"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "wallets", force: :cascade do |t|
    t.integer "user_id"
    t.string  "customer_id"
    t.decimal "balance",      precision: 8, scale: 2, default: 0.0
    t.decimal "amt_paid",     precision: 8, scale: 2
    t.decimal "amt_received", precision: 8, scale: 2
    t.string  "last4"
    t.string  "brand"
  end

  add_index "wallets", ["user_id"], name: "index_wallets_on_user_id", using: :btree

  add_foreign_key "deliveryslots", "orders"
  add_foreign_key "deliveryslots", "timeslots"
  add_foreign_key "locations", "orders"
  add_foreign_key "orderitems", "items"
  add_foreign_key "orderitems", "orders"
  add_foreign_key "orderitems", "users"
  add_foreign_key "orders", "users"
  add_foreign_key "reviews", "users"
end
