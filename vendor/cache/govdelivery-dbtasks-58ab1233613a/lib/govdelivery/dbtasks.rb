require "govdelivery/dbtasks/version"

require "active_record"
require 'active_record/connection_adapters/oracle_enhanced_adapter'

require "ruby-plsql"
require 'govdelivery/active_record/safe_migration'
require 'govdelivery/active_record/migration'
require 'govdelivery/active_record/schema_migration'
require 'govdelivery/active_record/tasks/database_tasks'
require 'govdelivery/active_record/connection_adapters/oracle_enhanced_adapter'
require 'govdelivery/active_record/connection_adapters/oracle_enhanced_current_schema_adapter'
require 'govdelivery/active_record/connection_adapters/oracle_enhanced_connection'
require 'govdelivery/active_record/connection_adapters/oracle_enhanced/current_schema_structure_dump'
require 'govdelivery/active_record/connection_adapters/oracle_enhanced_current_schema_oci_connection'

require 'govdelivery/active_record/connection_adapters/oracle_enhanced/current_schema_statements'

module Govdelivery
  module Dbtasks
    require 'govdelivery/dbtasks/railtie' if defined?(Rails)
  end
end
