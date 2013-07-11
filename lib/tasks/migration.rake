namespace :db do
  namespace :migrate do
    DB_PATH = ActiveRecord::Migrator.migrations_path
    SEPARATOR = " --- "

    def run_command(command)
      %x(#{command}).tap do |result|
        status = $?
        unless status.success?
          raise "Command Error -- (#{status.exitstatus}): [#{command}]"
        end
        result
      end
    end

    def generate_schema_dump
      Rake::Task["db:schema:dump"].invoke
    end

    def run_migrations
      Rake::Task["db:migrate"].invoke
    end

    def ordinal_position_of_migration
      output = run_command("ls #{DB_PATH} | awk '{ print NR \"#{SEPARATOR}\" $0 }'")
      output.split("\n").
             map { |migration| migration.split(SEPARATOR) }.
             select { |migration| migration[1] =~ Regexp.new(UPTO) }.flatten.first.to_i
    end

    def remove_list_of_migrations
      upto = ordinal_position_of_migration
      remove_schema_migrations(upto - 1)
      remove_files(upto)
    end

    def remove_schema_migrations(upto)
      removables = run_command("ls #{DB_PATH}/* | head -n#{upto}").split("\n")
      timestamps = removables.map { |file| timestamp_of_migration(File.basename(file, ".rb")) }
      sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, ["delete from schema_migrations where version IN (?)", timestamps])
      ActiveRecord::Base.connection.execute(sanitized_sql)
    end

    def remove_files(upto)
      run_command("ls #{DB_PATH}/* | head -n#{upto} | xargs rm -v")
    end

    def timestamp_of_migration(file)
      file.split("_").first
    end

    def extract_schema_dump
      dump = StringIO.new
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, dump)

      dump.string.
           split("\n").
           reject { |line| line =~ /^ActiveRecord::Schema.define/ }.
           map {|line| line.gsub(", :force => true", "")}.
           join("\n")
    end

    def indented_schema_dump(times)
      extract_schema_dump.split("\n").
                          map { |line| line.insert(0, " " * times) if line.present? }.
                          join("\n")
    end

    def create_migration_file
      template = <<-EOS
class RebaseOldMigrations < ActiveRecord::Migration
  def change
#{indented_schema_dump(2)}
end
EOS

      file = UPTO + "_rebase_old_migrations.rb"
      migration_file = File.join(DB_PATH, file)
      File.open(migration_file, 'w') { |mf| mf.write(template) }
    end

    desc "Squash/Rebase all migrations upto a certain point"
    task :rebase do
      UPTO = timestamp_of_migration(ENV['UPTO'] || run_command("ls #{DB_PATH} | tail -n1"))

      puts "* Generating schema dump..."
      generate_schema_dump

      puts "* Removing old migrations..."
      remove_list_of_migrations

      puts "* Creating squashed migration file..."
      create_migration_file

      puts "* Running the migrations as a sanity check..."
      run_migrations

      puts "* Done. See #{DB_PATH}."
    end
  end
end
