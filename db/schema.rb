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

ActiveRecord::Schema.define(version: 20140308050934) do

  create_table "client_browsers", force: true do |t|
    t.string   "browser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_oses", force: true do |t|
    t.string   "os"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_platforms", force: true do |t|
    t.string   "platform"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

end
