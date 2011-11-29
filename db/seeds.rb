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
Setup.create({ key: "smtp_user_name", value: "notifications@nines.org" })
Setup.create({ key: "smtp_password", value: "n!ght99" })
Setup.create({ key: "smtp_authentication", value: "plain" })
Setup.create({ key: "project_manager_email", value: "dana@nines.org" })
Setup.create({ key: "webmaster_email", value: "technologies@nines.org" })
Setup.create({ key: "exception_recipients", value: "paul@performantsoftware.com" })
Setup.create({ key: "sender_name", value: "Application Error" })
Setup.create({ key: "subject_prefix", value: "[18th] " })
Setup.create({ key: "site_name", value: "18thConnect" })
Setup.create({ key: "site_title", value: "18thConnect" })
Setup.create({ key: "site_my_collex", value: "My18th" })
Setup.create({ key: "site_default_federation", value: "18thConnect" })
Setup.create({ key: "site_about_label_1", value: "What is 18thConnect?" })
Setup.create({ key: "site_about_url_1", value: "/18th_about/what_is.html" })
Setup.create({ key: "site_about_label_2", value: "Peer Review" })
Setup.create({ key: "site_about_url_2", value: "/18th_about/peerReview.html" })
Setup.create({ key: "site_solr_url", value: "http://catalog.performantsoftware.com" })
Setup.create({ key: "google_analytics", value: "false" })
Setup.create({ key: "analytics_id", value: "" })
