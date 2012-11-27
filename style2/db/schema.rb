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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121126202217) do

  create_table "markov_sources", :id => false, :force => true do |t|
    t.integer "markov_id"
    t.integer "source_id"
  end

  create_table "markovs", :force => true do |t|
    t.string   "name"
    t.string   "author"
    t.integer  "paircount"
    t.text     "ngrams"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reports", :force => true do |t|
    t.integer  "source_id"
    t.integer  "markov_id"
    t.float    "model_probability"
    t.float    "universe_probability"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "sources", :force => true do |t|
    t.string   "title"
    t.string   "author"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
