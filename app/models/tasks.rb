class Tasks < ActiveRecord::Base
	validates_presence_of :archive_name, :file_name
	validates_uniqueness_of :file_name
	validates_format_of 	:file_name,
				:with		=> %r{\.(rdf|zip|xml)$}i,
				:message	=> "must be a .zip, .rdf, or .xml file"
end
