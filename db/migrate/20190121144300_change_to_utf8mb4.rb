class ChangeToUtf8mb4 < ActiveRecord::Migration[5.1]
  def change
    config = Rails.configuration.database_configuration
    db_name = config[Rails.env]["database"]
    char_set = 'utf8mb4'
 
    execute("ALTER DATABASE #{db_name} CHARACTER SET #{char_set};")
 
    ActiveRecord::Base.connection.tables.each do |table|
      execute("ALTER TABLE #{table} CONVERT TO CHARACTER SET #{char_set};")
    end
  end
end
