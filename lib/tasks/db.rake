desc "Clean up Active Record sessions updated before ENV['EXPIRE_AT'] (defaults to 3 weeks ago)."
task :clean_ar_sessions => :environment do
  time = ENV['EXPIRE_AT'] || 3.weeks.ago.to_s(:db)
  rows = CGI::Session::ActiveRecordStore::Session.delete_all ["updated_at < ?", time]
  RAILS_DEFAULT_LOGGER.info "#{rows} session row(s) deleted."
end
