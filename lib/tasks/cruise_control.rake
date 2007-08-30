# Cruise Control custom task: CC will run this task by default, or we can call it in cruise_config.rb.

desc 'custom cruise control task'
task :cruise do
  Rake::Task["db:migrate"].invoke rescue got_error = true
  Rake::Task["db:test:purge"].invoke rescue got_error = true
  Rake::Task["test"].invoke rescue got_error = true
  Rake::Task["spec"].invoke rescue got_error = true

  raise "Test failures" if got_error
end  
