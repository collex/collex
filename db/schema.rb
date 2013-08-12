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

ActiveRecord::Schema.define(:version => 20130812173759) do

  create_table "cached_properties", :force => true do |t|
    t.string  "name"
    t.string  "value"
    t.integer "cached_resource_id"
  end

  add_index "cached_properties", ["cached_resource_id"], :name => "index_cached_properties_on_cached_resource_id"
  add_index "cached_properties", ["name"], :name => "index_cached_properties_on_name"
  add_index "cached_properties", ["value"], :name => "index_cached_properties_on_value"

  create_table "cached_resources", :force => true do |t|
    t.string "uri"
  end

  add_index "cached_resources", ["uri"], :name => "index_cached_resources_on_uri"

  create_table "clusters", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "group_id",    :precision => 10, :scale => 0
    t.decimal  "image_id",    :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "visible_url"
    t.string   "visibility"
  end

  create_table "collected_items", :force => true do |t|
    t.decimal  "user_id",            :precision => 10, :scale => 0
    t.decimal  "cached_resource_id", :precision => 10, :scale => 0
    t.text     "annotation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_reports", :force => true do |t|
    t.integer  "discussion_comment_id"
    t.string   "reason"
    t.integer  "reporter_id"
    t.datetime "reported_on"
  end

  create_table "constraints", :force => true do |t|
    t.integer "search_id"
    t.boolean "inverted"
    t.string  "type"
    t.string  "fieldx"
    t.string  "value"
  end

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "user_modified_at"
    t.string   "link_title"
  end

  create_table "discussion_threads", :force => true do |t|
    t.integer  "discussion_topic_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "number_of_views",     :precision => 10, :scale => 0
    t.decimal  "license",             :precision => 10, :scale => 0
    t.decimal  "group_id",            :precision => 10, :scale => 0
    t.decimal  "cluster_id",          :precision => 10, :scale => 0
  end

  create_table "discussion_topics", :force => true do |t|
    t.string   "topic"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "position",    :precision => 10, :scale => 0
    t.text     "description"
  end

  create_table "discussion_visits", :force => true do |t|
    t.integer  "user_id"
    t.integer  "discussion_thread_id"
    t.datetime "last_visit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exhibit_elements", :force => true do |t|
    t.decimal  "exhibit_section_id",          :precision => 10, :scale => 0
    t.decimal  "position",                    :precision => 10, :scale => 0
    t.string   "exhibit_element_layout_type"
    t.text     "element_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "border_type_enum",            :precision => 10, :scale => 0
    t.decimal  "exhibit_page_id",             :precision => 10, :scale => 0
    t.text     "element_text2"
    t.decimal  "justify",                     :precision => 10, :scale => 0
    t.decimal  "header_footnote_id",          :precision => 10, :scale => 0
  end

  create_table "exhibit_footnotes", :force => true do |t|
    t.text     "footnote"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exhibit_illustrations", :force => true do |t|
    t.decimal  "exhibit_element_id",   :precision => 10, :scale => 0
    t.decimal  "position",             :precision => 10, :scale => 0
    t.string   "illustration_type"
    t.string   "image_url"
    t.text     "illustration_text"
    t.text     "caption1"
    t.text     "caption2"
    t.decimal  "image_width",          :precision => 10, :scale => 0
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alt_text"
    t.string   "nines_object_uri"
    t.decimal  "height",               :precision => 10, :scale => 0
    t.decimal  "caption1_footnote_id", :precision => 10, :scale => 0
    t.decimal  "caption2_footnote_id", :precision => 10, :scale => 0
    t.decimal  "caption1_bold",        :precision => 10, :scale => 0
    t.decimal  "caption1_italic",      :precision => 10, :scale => 0
    t.decimal  "caption1_underline",   :precision => 10, :scale => 0
    t.decimal  "caption2_bold",        :precision => 10, :scale => 0
    t.decimal  "caption2_italic",      :precision => 10, :scale => 0
    t.decimal  "caption2_underline",   :precision => 10, :scale => 0
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
  end

  create_table "exhibit_objects", :force => true do |t|
    t.string   "uri"
    t.integer  "exhibit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exhibit_pages", :force => true do |t|
    t.decimal  "exhibit_id", :precision => 10, :scale => 0
    t.decimal  "position",   :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exhibits", :force => true do |t|
    t.string   "title"
    t.decimal  "user_id",                 :precision => 10, :scale => 0
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "visible_url"
    t.decimal  "is_published",            :precision => 10, :scale => 0
    t.decimal  "thumbleft",               :precision => 10, :scale => 0
    t.decimal  "thumbwidth",              :precision => 10, :scale => 0
    t.decimal  "thumbtop",                :precision => 10, :scale => 0
    t.decimal  "alias_id",                :precision => 10, :scale => 0
    t.string   "header_font_name"
    t.string   "header_font_size"
    t.string   "illustration_font_name"
    t.string   "illustration_font_size"
    t.string   "text_font_name"
    t.string   "text_font_size"
    t.string   "caption1_font_name"
    t.string   "caption1_font_size"
    t.string   "caption2_font_name"
    t.string   "caption2_font_size"
    t.string   "endnotes_font_name"
    t.string   "endnotes_font_size"
    t.string   "footnote_font_name"
    t.string   "footnote_font_size"
    t.datetime "last_change"
    t.text     "genres"
    t.string   "resource_name"
    t.decimal  "group_id",                :precision => 10, :scale => 0
    t.decimal  "license_type",            :precision => 10, :scale => 0
    t.decimal  "cluster_id",              :precision => 10, :scale => 0
    t.string   "editor_limit_visibility"
    t.string   "additional_authors"
    t.text     "disciplines"
  end

  create_table "facet_categories", :force => true do |t|
    t.integer "parent_id"
    t.string  "value"
    t.string  "type"
    t.decimal "carousel_include",     :precision => 10, :scale => 0
    t.text    "carousel_description"
    t.string  "carousel_url"
    t.decimal "image_id",             :precision => 10, :scale => 0
  end

  create_table "featured_objects", :force => true do |t|
    t.string   "object_uri"
    t.string   "title"
    t.string   "object_url"
    t.string   "date"
    t.string   "site"
    t.string   "site_url"
    t.string   "saved_search_name"
    t.string   "saved_search_url"
    t.decimal  "image_id",          :precision => 10, :scale => 0
    t.string   "disabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.decimal  "owner",                       :precision => 10, :scale => 0
    t.text     "description"
    t.string   "group_type"
    t.decimal  "image_id",                    :precision => 10, :scale => 0
    t.string   "forum_permissions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "license_type",                :precision => 10, :scale => 0
    t.string   "header_font_name"
    t.string   "header_font_size"
    t.string   "illustration_font_name"
    t.string   "illustration_font_size"
    t.string   "text_font_name"
    t.string   "text_font_size"
    t.string   "caption1_font_name"
    t.string   "caption1_font_size"
    t.string   "caption2_font_name"
    t.string   "caption2_font_size"
    t.string   "endnotes_font_name"
    t.string   "endnotes_font_size"
    t.string   "footnote_font_name"
    t.string   "footnote_font_size"
    t.decimal  "use_styles",                  :precision => 10, :scale => 0
    t.boolean  "show_membership"
    t.string   "exhibit_visibility"
    t.string   "university"
    t.string   "course_name"
    t.string   "course_mnemonic"
    t.string   "show_exhibits"
    t.string   "visible_url"
    t.string   "exhibits_label"
    t.string   "clusters_label"
    t.string   "show_admins"
    t.decimal  "badge_id",                    :precision => 10, :scale => 0
    t.decimal  "publication_image_id",        :precision => 10, :scale => 0
    t.string   "notifications"
    t.string   "header_color"
    t.string   "header_background_color"
    t.string   "link_color"
    t.string   "exhibit_header_color"
    t.string   "exhibit_text_color"
    t.string   "exhibit_caption1_color"
    t.string   "exhibit_caption1_background"
    t.string   "exhibit_caption2_color"
    t.string   "exhibit_caption2_background"
  end

  create_table "groups_users", :force => true do |t|
    t.decimal  "group_id",        :precision => 10, :scale => 0
    t.decimal  "user_id",         :precision => 10, :scale => 0
    t.string   "email"
    t.string   "role"
    t.boolean  "pending_invite"
    t.boolean  "pending_request"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notifications"
  end

  create_table "image_fulls", :force => true do |t|
    t.integer  "parent_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.string   "photo_updated_at"
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
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.string   "photo_file_size"
    t.string   "photo_updated_at"
  end

  create_table "iso_languages", :force => true do |t|
    t.string   "alpha3"
    t.string   "alpha2"
    t.string   "english_name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "login_infos", :force => true do |t|
    t.string   "username"
    t.string   "address"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "object_activities", :force => true do |t|
    t.string   "username"
    t.string   "action"
    t.string   "uri"
    t.string   "tagname"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "peer_reviews", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "image_full_id", :precision => 10, :scale => 0
  end

  create_table "publication_images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "image_full_id", :precision => 10, :scale => 0
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "search_user_contents", :force => true do |t|
    t.datetime "last_indexed"
    t.decimal  "seconds_spent_indexing", :precision => 10, :scale => 3
    t.decimal  "objects_indexed",        :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "obj_type"
  end

  create_table "searches", :force => true do |t|
    t.string  "name"
    t.integer "user_id"
    t.string  "sort_by"
    t.string  "sort_dir"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data",       :limit => 16777215
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "setups", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sites", :force => true do |t|
    t.string "code"
    t.string "url"
    t.string "description"
    t.string "thumbnail"
  end

  create_table "tagassigns", :force => true do |t|
    t.decimal  "tag_id",             :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cached_resource_id"
    t.integer  "user_id"
  end

  create_table "tags", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_on"
  end

  add_index "tags", ["name"], :name => "tags_name", :unique => true

  create_table "tw_featured_objects", :force => true do |t|
    t.string   "uri"
    t.boolean  "primary"
    t.boolean  "disabled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string  "username"
    t.string  "password_hash"
    t.string  "fullname"
    t.string  "email"
    t.string  "institution"
    t.string  "link"
    t.text    "about_me"
    t.decimal "image_id",      :precision => 10, :scale => 0
    t.string  "hide_email"
  end

  create_table "vic_conferences", :force => true do |t|
    t.string   "price"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "university"
    t.string   "phone"
    t.string   "email"
    t.string   "title"
    t.text     "accessibility"
    t.text     "audio_visual"
    t.string   "rare_book_school_1"
    t.string   "rare_book_school_2"
    t.string   "lunch_friday"
    t.string   "lunch_saturday"
    t.string   "lunch_vegetarian"
    t.string   "parking"
    t.string   "transaction_id"
    t.string   "amt_paid"
    t.string   "auth_status"
    t.string   "auth_code"
    t.string   "avs_code"
    t.text     "error_txt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
