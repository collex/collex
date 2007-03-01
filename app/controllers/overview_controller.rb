class OverviewController < ApplicationController
	def index
		#@exchanges = Exchange.find_by_sql("SELECT * FROM exchanges WHERE task_id = '"+ params['id'] +"'")
		@exchanges = Exchange.find_all_by_task_id_and_item(params['id'],"Item added successfully to sql database approval queue")
		#@errors = Error.find_by_sql("SELECT * FROM errors WHERE task_id = '"+ params['id'] + "'")
		@generalerrors = Error.find(:all, :conditions => { :task_id=> params['id'], :uri => 'NA'}).map{ |i| i.item }.uniq
	
		#Error.find_all_by_uri('NA')
		#@errorsbytask = Error.find_all_by_task_id(params['id')

		@errors = Error.find(:all, :conditions => { :task_id => params['id']}).map{ |i| i.uri }.uniq
		#
		#@errors = Error.find(:all, :conditions => {:id => params['id'] })
		#Student.find(:all, :conditions => { :first_name => "Harvey", :status => 1 })
	
	end
end
