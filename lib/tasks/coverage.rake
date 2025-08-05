namespace :test do
  desc "Run tests with SimpleCov coverage reporting"
  task :coverage do
    puts "Running tests with SimpleCov coverage reporting..."
    puts "Coverage report will be generated in /coverage directory"
    
    # Set environment to test
    ENV["RAILS_ENV"] = "test"
    
    # Run the default test task which will use our SimpleCov configuration
    Rake::Task["test"].invoke
    
    puts "\nCoverage report generated!"
    puts "Open coverage/index.html in a browser to view the detailed report"
  end
end