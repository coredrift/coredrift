namespace :db do
  desc "Completely reset the database, schema, and seed data"
  task full_reset: :environment do
    puts "Removing schema.rb..."
    File.delete(Rails.root.join("db", "schema.rb")) if File.exist?(Rails.root.join("db", "schema.rb"))

    puts "Dropping database..."
    Rake::Task["db:drop"].invoke

    puts "Creating database..."
    Rake::Task["db:create"].invoke

    puts "Running migrations..."
    Rake::Task["db:migrate"].invoke

    puts "Checking migration status..."
    Rake::Task["db:migrate:status"].invoke

    puts "Seeding database..."
    Rake::Task["db:seed"].invoke

    puts "Database reset complete!"
  end

  namespace :full_reset do
    desc "Completely reset the test database, schema, and seed data"
    task test: :environment do
      puts "Setting RAILS_ENV to test..."
      Rails.env = "test"

      puts "Removing schema.rb..."
      File.delete(Rails.root.join("db", "schema.rb")) if File.exist?(Rails.root.join("db", "schema.rb"))

      puts "Dropping test database..."
      Rake::Task["db:drop"].invoke

      puts "Creating test database..."
      Rake::Task["db:create"].invoke

      puts "Running migrations..."
      Rake::Task["db:migrate"].invoke

      puts "Checking migration status..."
      Rake::Task["db:migrate:status"].invoke

      puts "Reconnecting to database..."
      ActiveRecord::Base.connection.reconnect!

      puts "Seeding test database..."
      Rake::Task["db:seed"].invoke

      puts "Test database reset complete!"
    end
  end
end
