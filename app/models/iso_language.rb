class IsoLanguage < ActiveRecord::Base
  attr_accessible :alpha2, :alpha3, :english_name, :occurrences

  def first_english_name
    if self.english_name
      return self.english_name.split(/\;/).first
    else
      return nil
    end
  end
end
