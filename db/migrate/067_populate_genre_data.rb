require 'active_record/fixtures' 

class PopulateGenreData < ActiveRecord::Migration 

def self.up 
  down 
  Fixtures.create_fixtures(File.dirname(__FILE__), "genres") 
end 

def self.down 
  Genre.delete_all 
end

end 
