class RemoveTextExhibitType < ActiveRecord::Migration
  class ExhibitType < ActiveRecord::Base
  end

  def self.up
    ExhibitType.find_by_template("text").destroy rescue nil
  end

  # text was never used, so we don't need to return it to the db
  def self.down
  end
end
