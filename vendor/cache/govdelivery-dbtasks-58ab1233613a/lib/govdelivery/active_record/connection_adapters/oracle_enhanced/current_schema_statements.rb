# -*- coding: utf-8 -*-
require 'digest/sha1'

module ActiveRecord
  module ConnectionAdapters
    module OracleEnhanced
      module CurrentSchemaStatements

        # REFERENTIAL INTEGRITY ====================================

        # modified from v1.6.6 - use current_schema to figure out what to disable
        def disable_referential_integrity(&block) #:nodoc:
          # only
          sql_constraints = %q|
              SELECT c.owner, c.table_name, c.constraint_name
                       FROM all_constraints c, all_tables t
                       WHERE c.table_name = t.table_name
                       AND c.owner = SYS_CONTEXT('userenv', 'current_schema')
                       AND t.owner = SYS_CONTEXT('userenv', 'current_schema')
                       AND c.constraint_type = 'R' -- foreign key|
          old_constraints = select_all(sql_constraints)
          begin
            old_constraints.each do |constraint|
              execute "ALTER TABLE #{constraint['owner']}.#{constraint["table_name"]} DISABLE CONSTRAINT #{constraint["constraint_name"]}"
            end
            yield
          ensure
            old_constraints.each do |constraint|
              execute "ALTER TABLE #{constraint['owner']}.#{constraint["table_name"]} ENABLE CONSTRAINT #{constraint["constraint_name"]}"
            end
          end
        end


        def foreign_keys(table_name) #:nodoc:
          if defined?(OracleEnhanced::ForeignKeyDefinition)
            foreign_keys_16(table_name)
          else
            foreign_keys_14(table_name)
          end
        end

        # get table foreign keys for schema dump
        def foreign_keys_14(table_name) #:nodoc:
          (owner, desc_table_name, db_link) = @connection.describe(table_name)

          fk_info = select_all(<<-SQL, 'Foreign Keys')
             SELECT /*+ leading(c r cc rc) no_query_transformation */
                    r.table_name to_table
                   ,rc.column_name references_column
                   ,cc.column_name
                   ,c.constraint_name name
                   ,c.delete_rule
               FROM all_constraints#{db_link} c, all_cons_columns#{db_link} cc,
                    all_constraints#{db_link} r, all_cons_columns#{db_link} rc
              WHERE c.owner = '#{owner}'
                AND c.table_name = '#{desc_table_name}'
                AND c.constraint_type = 'R'
                AND cc.owner = c.owner
                AND cc.constraint_name = c.constraint_name
                AND r.constraint_name = c.r_constraint_name
                AND r.owner = c.owner
                AND rc.owner = r.owner
                AND rc.constraint_name = r.constraint_name
                AND rc.position = cc.position
             ORDER BY name, to_table, column_name, references_column
           SQL

          fks = {}

          fk_info.map do |row|
            name      = oracle_downcase(row['name'])
            fks[name] ||= {:columns => [], :to_table => oracle_downcase(row['to_table']), :references => []}
            fks[name][:columns] << oracle_downcase(row['column_name'])
            fks[name][:references] << oracle_downcase(row['references_column'])
            case row['delete_rule']
              when 'CASCADE'
                fks[name][:dependent] = :delete
              when 'SET NULL'
                fks[name][:dependent] = :nullify
            end
          end

          fks.map do |k, v|
            options = {:name => k, :columns => v[:columns], :references => v[:references], :dependent => v[:dependent]}
            OracleEnhancedForeignKeyDefinition.new(table_name, v[:to_table], options)
          end
        end

        # get table foreign keys for schema dump
        def foreign_keys_16(table_name) #:nodoc:
          (owner, desc_table_name, db_link) = @connection.describe(table_name)

          # Oracle Support Document 796359.1
          # (SUB-OPTIMAL PLAN FOR JDBC GENERATED SQL USING ALL_CONSTRAINTS AND ALL_CONS_COLUMNS)
          # https://support.oracle.com/epmos/faces/DocumentDisplay?id=796359.1
          fk_info = select_all(<<-SQL, 'Foreign Keys')
            SELECT /*+ leading(c r cc rc) no_query_transformation */
                   r.table_name to_table
                  ,rc.column_name references_column
                  ,cc.column_name
                  ,c.constraint_name name
                  ,c.delete_rule
              FROM all_constraints#{db_link} c, all_cons_columns#{db_link} cc,
                   all_constraints#{db_link} r, all_cons_columns#{db_link} rc
             WHERE c.owner = '#{owner}'
               AND c.table_name = '#{desc_table_name}'
               AND c.constraint_type = 'R'
               AND cc.owner = c.owner
               AND cc.constraint_name = c.constraint_name
               AND r.constraint_name = c.r_constraint_name
               AND r.owner = c.owner
               AND rc.owner = r.owner
               AND rc.constraint_name = r.constraint_name
               AND rc.position = cc.position
            ORDER BY name, to_table, column_name, references_column
          SQL

          fk_info.map do |row|
            options = {
              column: oracle_downcase(row['column_name']),
              name: oracle_downcase(row['name']),
              primary_key: oracle_downcase(row['references_column'])
            }
            options[:on_delete] = extract_foreign_key_action(row['delete_rule'])
            OracleEnhanced::ForeignKeyDefinition.new(oracle_downcase(table_name), oracle_downcase(row['to_table']), options)
          end
        end

      end
    end
  end
end

ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.class_eval do
  include ActiveRecord::ConnectionAdapters::OracleEnhanced::CurrentSchemaStatements
end
