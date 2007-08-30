# TODO, this file should be renamed, since it has the lib tests.
# Alternatively, the lib task could be put in its own rake file.

desc 'custom cruise control task'
task :cruise do
  Rake::Task["db:migrate"].invoke rescue got_error = true
  Rake::Task["test"].invoke rescue got_error = true
  Rake::Task["spec"].invoke rescue got_error = true

  raise "Test failures" if got_error
end  
