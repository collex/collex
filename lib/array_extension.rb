class Array
  # This is to deal with Solr response pieces more easily, which come back as [key,value,key,value] arrays.
  def to_hash
    h = {}
    0.upto(size / 2 - 1) do |i|
      n = i * 2
      h[self[n]] = self[n+1]
    end
    
    h
  end
end
