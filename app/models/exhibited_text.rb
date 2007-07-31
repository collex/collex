class ExhibitedText < ExhibitedItem
  
  # writers defined in parent
  def annotation_message
    @annotation_message || "(Insert Text)"
  end
  
end