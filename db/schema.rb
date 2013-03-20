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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130319103549) do

  create_table "answers", :force => true do |t|
    t.text     "content"
    t.integer  "question_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "response_id"
    t.string   "photo"
    t.string   "photo_secure_token"
    t.string   "photo_tmp"
    t.integer  "record_id"
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"
  add_index "answers", ["response_id"], :name => "index_answers_on_response_id"

  create_table "categories", :force => true do |t|
    t.integer  "category_id"
    t.text     "content"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "survey_id"
    t.integer  "order_number"
    t.integer  "parent_id"
    t.string   "type"
    t.boolean  "mandatory",    :default => false
  end

  add_index "categories", ["category_id"], :name => "index_categories_on_category_id"

  create_table "choices", :force => true do |t|
    t.integer  "answer_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "option_id"
  end

  add_index "choices", ["answer_id"], :name => "index_choices_on_answer_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.string   "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "oauth_applications", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "uid",          :null => false
    t.string   "secret",       :null => false
    t.string   "redirect_uri", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "options", :force => true do |t|
    t.string   "content"
    t.integer  "question_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "order_number"
  end

  add_index "options", ["question_id"], :name => "index_options_on_question_id"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "status",         :default => "active"
    t.string   "default_locale", :default => "en"
    t.string   "org_type"
  end

  create_table "participating_organizations", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "questions", :force => true do |t|
    t.text     "content"
    t.integer  "survey_id"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.boolean  "mandatory",                       :default => false
    t.integer  "max_length",         :limit => 8
    t.string   "type"
    t.integer  "max_value",          :limit => 8
    t.integer  "min_value"
    t.integer  "order_number"
    t.integer  "parent_id"
    t.boolean  "identifier",                      :default => false
    t.integer  "category_id"
    t.string   "image"
    t.string   "photo_secure_token"
    t.string   "image_tmp"
  end

  add_index "questions", ["survey_id"], :name => "index_questions_on_survey_id"

  create_table "records", :force => true do |t|
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "response_id"
  end

  create_table "responses", :force => true do |t|
    t.integer  "survey_id"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "status",          :default => "incomplete"
    t.string   "session_token"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "location"
    t.string   "ip_address"
    t.string   "mobile_id"
    t.string   "state",           :default => "clean"
    t.text     "comment"
  end

  add_index "responses", ["organization_id"], :name => "index_responses_on_organization_id"
  add_index "responses", ["survey_id"], :name => "index_responses_on_survey_id"

  create_table "survey_users", :force => true do |t|
    t.integer  "survey_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "surveys", :force => true do |t|
    t.string   "name"
    t.date     "expiry_date"
    t.text     "description"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "finalized",       :default => false
    t.integer  "organization_id"
    t.boolean  "public",          :default => false
    t.string   "auth_key"
    t.date     "published_on"
    t.boolean  "archived",        :default => false
  end

  add_index "surveys", ["organization_id"], :name => "index_surveys_on_organization_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "role"
    t.integer  "organization_id"
    t.string   "password_reset_token"
    t.string   "status"
  end

end
