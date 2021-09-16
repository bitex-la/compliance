# System class exposes stats and other system administration tasks.
class System
  def self.truncate
    return if Rails.env.production?

    Attachment.all.each{|a| a.document.destroy }

    conn = ActiveRecord::Base.connection
    conn.execute "SET FOREIGN_KEY_CHECKS = 0"
    all = conn.tables - %w(admin_users ar_internal_metadata schema_migrations)
    all.each{|table| conn.execute("truncate table #{table}") }
    conn.execute "SET FOREIGN_KEY_CHECKS = 1"
    EventLog.purge_sqs_queue

    return true
  end
end
