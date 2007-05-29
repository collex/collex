class Guest
  def id
    -1
  end
  
  def admin_role?
    false
  end
  
  def guest_role?
    true
  end
  
  def username
    "guest"
  end
  
end