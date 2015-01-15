module Monogamy
  module MySQL
    # See http://dev.mysql.com/doc/refman/5.0/en/lock-tables-and-transactions.html
    def self.with_table_lock(connection, quoted_table_name, &block)
      auto_commit = connection.execute("SELECT @@AUTOCOMMIT FROM DUAL").to_a.flatten.first
      begin
        connection.execute("SET autocommit=0")
        connection.execute("LOCK TABLES #{quoted_table_name} WRITE")
        connection.transaction do
          yield
        end
      ensure
        connection.execute("UNLOCK TABLES")
        connection.execute("SET autocommit=#{auto_commit}")
      end
    end
  end
end
