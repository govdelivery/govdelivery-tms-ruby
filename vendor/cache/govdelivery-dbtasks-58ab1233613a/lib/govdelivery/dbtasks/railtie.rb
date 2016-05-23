require 'govdelivery/dbtasks'
require 'rails'
module GovDelivery
  module Dbtasks
    class Railtie < Rails::Railtie
      railtie_name :govdelivery_dbtasks

      rake_tasks do
        load 'govdelivery/active_record/connection_adapters/oracle_enhanced/database_tasks.rb'
        load 'govdelivery/dbtasks/databases.rake'
      end
    end
  end
end
