# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Setup.destroy_all

Setup.create({ key: "smtp_address", value: "smtp.gmail.com" })
Setup.create({ key: "smtp_port", value: "587" })
Setup.create({ key: "smtp_user_name", value: "notifications@institution.edu" })
Setup.create({ key: "smtp_password", value: "super-secret" })
Setup.create({ key: "smtp_authentication", value: "plain" })
Setup.create({ key: "project_manager_email", value: "manager@institution.edu" })
Setup.create({ key: "webmaster_email", value: "webmaster@institution.edu" })
Setup.create({ key: "exception_recipients", value: "manager@institution.edu,webmaster@institution.edu" })
Setup.create({ key: "sender_name", value: "Application Error" })
Setup.create({ key: "subject_prefix", value: "[Collex:Dev] " })
Setup.create({ key: "site_name", value: "COLLEX" })
Setup.create({ key: "site_title", value: "C O L L E X" })
Setup.create({ key: "site_my_collex", value: "MyCollex" })
Setup.create({ key: "site_default_federation", value: "NINES" })
Setup.create({ key: "site_about_label_1", value: "What is Collex?" })
Setup.create({ key: "site_about_url_1", value: "/about/what_is.html" })
Setup.create({ key: "site_about_label_2", value: "Peer Review" })
Setup.create({ key: "site_about_url_2", value: "/about/peer_review.html" })
Setup.create({ key: "site_solr_url", value: "http://catalog.arc.com" })
Setup.create({ key: "google_analytics", value: "false" })
Setup.create({ key: "analytics_id", value: "" })
