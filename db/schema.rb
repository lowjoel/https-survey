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

ActiveRecord::Schema.define(version: 20140312103041) do

  create_table "client_browsers", force: true do |t|
    t.string   "browser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_browsers", ["browser"], name: "index_client_browsers_on_browser", unique: true, using: :btree

  create_table "client_oses", force: true do |t|
    t.string   "os"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_oses", ["os"], name: "index_client_oses_on_os", unique: true, using: :btree

  create_table "client_platforms", force: true do |t|
    t.string   "platform"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_platforms", ["platform"], name: "index_client_platforms_on_platform", unique: true, using: :btree

  create_table "client_samples", force: true do |t|
    t.string   "ip_address"
    t.integer  "protocol"
    t.string   "useragent"
    t.integer  "browser_id"
    t.string   "version"
    t.integer  "platform_id"
    t.integer  "os_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_samples", ["browser_id"], name: "index_client_samples_on_browser_id", using: :btree
  add_index "client_samples", ["os_id"], name: "index_client_samples_on_os_id", using: :btree
  add_index "client_samples", ["platform_id"], name: "index_client_samples_on_platform_id", using: :btree
  add_index "client_samples", ["protocol"], name: "index_client_samples_on_protocol", using: :btree

  create_table "delayed_jobs", force: true do |t|
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

  create_table "server_most_visits", force: true do |t|
    t.integer  "rank"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "server_most_visits", ["rank"], name: "index_server_most_visits_on_rank", using: :btree
  add_index "server_most_visits", ["url"], name: "index_server_most_visits_on_url", unique: true, using: :btree

  create_table "server_ssl_test_results", force: true do |t|
    t.integer  "server_ssl_test_id"
    t.string   "ip"
    t.boolean  "ssl3"
    t.boolean  "tls1"
    t.boolean  "tls11"
    t.boolean  "tls12"
    t.integer  "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "server_ssl_tests", force: true do |t|
    t.integer  "server_most_visit_id"
    t.datetime "last_tested"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
