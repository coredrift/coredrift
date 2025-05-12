namespace :db do
  desc "Completely reset the database, schema, and seed data"
  task full_reset: :environment do
    puts "Removing schema.rb..."
    File.delete(Rails.root.join('db', 'schema.rb')) if File.exist?(Rails.root.join('db', 'schema.rb'))

    puts "Dropping database..."
    Rake::Task['db:drop'].invoke

    puts "Creating database..."
    Rake::Task['db:create'].invoke

    puts "Running migrations..."
    Rake::Task['db:migrate'].invoke

    puts "Checking migration status..."
    Rake::Task['db:migrate:status'].invoke

    puts "Seeding database..."
    Rake::Task['db:seed'].invoke

    puts "Database reset complete!"
  end
end