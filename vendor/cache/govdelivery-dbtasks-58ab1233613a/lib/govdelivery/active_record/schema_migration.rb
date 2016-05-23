module ActiveRecord
  class SchemaMigration < ActiveRecord::Base

    # The SchemaMigration is an ActiveRecord::Base class that can create/destroy
    # its own table.  So it will need to use the Migration's connection.

    def self.connection
      Migration.connection
    end

  end

end
