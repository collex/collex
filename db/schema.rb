# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090626135309) do

  create_table "cached_properties", :force => true do |t|
    t.string  "name"
    t.string  "value"
    t.integer "cached_resource_id"
  end

  add_index "cached_properties", ["name"], :name => "index_cached_properties_on_name"
  add_index "cached_properties", ["value"], :name => "index_cached_properties_on_value"

  create_table "cached_resources", :force => true do |t|
    t.string "uri"
  end

  add_index "cached_resources", ["uri"], :name => "index_cached_resources_on_uri"

  create_table "collected_items", :force => true do |t|
    t.integer  "user_id",            :limit => 10, :precision => 10, :scale => 0
    t.integer  "cached_resource_id", :limit => 10, :precision => 10, :scale => 0
    t.text     "annotation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "constraints", :force => true do |t|
    t.integer "search_id"
    t.boolean "inverted"
    t.string  "type"
    t.string  "field"
    t.string  "value"
  end

  create_table "discussion_comments", :force => true do |t|
    t.integer  "discussion_thread_id"
    t.integer  "user_id"
    t.integer  "position"
    t.integer  "comment_type"
    t.integer  "cached_resource_id"
    t.integer  "exhibit_id"
    t.string   "link_url"
    t.string   "image_url"
    t.text     "comment"
    t.integer  "reported"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "reporter_ids"
    t.datetime "user_modified_at"
  end

  create_table "discussion_threads", :force => true do |t|
    t.integer  "discussion_topic_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "number_of_views",     :limit => 10, :precision => 10, :scale => 0
  end

  create_table "discussion_topics", :force => true do |t|
    t.string   "topic"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",    :limit => 10, :precision => 10, :scale => 0
    t.text     "description"
  end

  create_table "exhibit_elements", :force => true do |t|
    t.integer  "exhibit_section_id",          :limit => 10, :precision => 10, :scale => 0
    t.integer  "position",                    :limit => 10, :precision => 10, :scale => 0
    t.string   "exhibit_element_layout_type"
    t.text     "element_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "border_type_enum",            :limit => 10, :precision => 10, :scale => 0
    t.integer  "exhibit_page_id",             :limit => 10, :precision => 10, :scale => 0
    t.text     "element_text2"
    t.integer  "justify",                     :limit => 10, :precision => 10, :scale => 0
  end

  create_table "exhibit_illustrations", :force => true do |t|
    t.integer  "exhibit_element_id", :limit => 10, :precision => 10, :scale => 0
    t.integer  "position",           :limit => 10, :precision => 10, :scale => 0
    t.string   "illustration_type"
    t.string   "image_url"
    t.text     "illustration_text"
    t.text     "caption1"
    t.text     "caption2"
    t.integer  "image_width",        :limit => 10, :precision => 10, :scale => 0
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alt_text"
    t.string   "nines_object_uri"
    t.integer  "height",             :limit => 10, :precision => 10, :scale => 0
  end

  create_table "exhibit_objects", :force => true do |t|
    t.string   "uri"
    t.integer  "exhibit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exhibit_pages", :force => true do |t|
    t.integer  "exhibit_id", :limit => 10, :precision => 10, :scale => 0
    t.integer  "position",   :limit => 10, :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exhibits", :force => true do |t|
    t.string   "title"
    t.integer  "user_id",      :limit => 10, :precision => 10, :scale => 0
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "visible_url"
    t.integer  "is_published", :limit => 10, :precision => 10, :scale => 0
    t.integer  "thumbleft",    :limit => 10, :precision => 10, :scale => 0
    t.integer  "thumbwidth",   :limit => 10, :precision => 10, :scale => 0
    t.integer  "thumbtop",     :limit => 10, :precision => 10, :scale => 0
    t.integer  "alias_id",     :limit => 10, :precision => 10, :scale => 0
    t.string   "category"
  end

  create_table "facet_categories", :force => true do |t|
    t.integer "parent_id"
    t.string  "value"
    t.string  "type"
    t.integer "carousel_include",     :limit => 10, :precision => 10, :scale => 0
    t.text    "carousel_description"
    t.string  "carousel_url"
    t.integer "image_id",             :limit => 10, :precision => 10, :scale => 0
  end

  create_table "images", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "login_infos", :force => true do |t|
    t.string   "username"
    t.string   "address"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logs", :force => true do |t|
    t.string   "user"
    t.string   "request_method"
    t.text     "request_uri"
    t.text     "http_referer"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "searches", :force => true do |t|
    t.string  "name"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.string "code"
    t.string "url"
    t.string "description"
    t.string "thumbnail"
  end

  create_table "tagassigns", :force => true do |t|
    t.integer  "collected_item_id", :limit => 10, :precision => 10, :scale => 0
    t.integer  "tag_id",            :limit => 10, :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name",       :default => "", :null => false
    t.datetime "created_on"
  end

  add_index "tags", ["name"], :name => "tags_name", :unique => true

  create_table "users", :force => true do |t|
    t.string  "username"
    t.string  "password_hash"
    t.string  "fullname"
    t.string  "email"
    t.string  "institution"
    t.string  "link"
    t.text    "about_me"
    t.integer "image_id",      :limit => 10, :precision => 10, :scale => 0
  end

end
