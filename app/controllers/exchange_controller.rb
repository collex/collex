class ExchangeController < ApplicationController
	def index
		#@exchanges = Exchange.find_by_sql("SELECT * FROM exchanges WHERE task_id = '"+ params['id'] +"'")
		@exchanges = Exchange.find_by_task_id(params['id'])
		#@errors = Error.find_by_sql("SELECT * FROM errors WHERE task_id = '"+ params['id'] + "'")
		@errors = Error.find_by_task_id(params['id'])
	end
end
