class Log < ActiveRecord::Base
  def self.append_record(session, env, params)
    user = session[:user] ? session[:user][:username] : nil

    str = ""
    for param in params
      str += "#{param[0]} => \"#{param[1]}\", " if param[0] != 'action' and param[0] != 'controller'
    end
    
    count = Log.count
    if count >= 10000
      log = Log.find(:first, :order => 'updated_at')
      log.user = user
      log.request_method = env['REQUEST_METHOD']
      log.request_uri = env['REQUEST_URI']
      log.http_referer = env["HTTP_REFERER"]
      log.params = str
      log.save
    else
      Log.create(:user => user, :request_method => env['REQUEST_METHOD'], :request_uri => env['REQUEST_URI'], :http_referer => env["HTTP_REFERER"], :params => str)
    end
    
  end
end
