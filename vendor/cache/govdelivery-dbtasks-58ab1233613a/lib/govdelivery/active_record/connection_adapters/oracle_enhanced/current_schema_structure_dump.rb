module ActiveRecord #:nodoc:
  module ConnectionAdapters #:nodoc:
    module OracleEnhanced
      module CurrentSchemaStructureDump #:nodoc:
        #
        # All this stuff refers to current_user in the gem impl, but we want to use current_schema
        #

        def structure_dump #:nodoc:
          structure = select_values("SELECT sequence_name FROM all_sequences WHERE owner = SYS_CONTEXT('userenv', 'current_schema') ORDER BY 1").map do |seq|
            "CREATE SEQUENCE \"#{seq}\""
          end
          select_values("SELECT table_name FROM all_tables t
                    WHERE owner = SYS_CONTEXT('userenv', 'current_schema') AND secondary = 'N'
                      AND NOT EXISTS (SELECT mv.mview_name FROM all_mviews mv WHERE mv.owner = t.owner AND mv.mview_name = t.table_name)
                      AND NOT EXISTS (SELECT mvl.log_table FROM all_mview_logs mvl WHERE mvl.log_owner = t.owner AND mvl.log_table = t.table_name)
                    ORDER BY 1").each do |table_name|
            virtual_columns = virtual_columns_for(table_name)
            ddl             = "CREATE#{ ' GLOBAL TEMPORARY' if temporary_table?(table_name)} TABLE \"#{table_name}\" (\n"
            cols            = select_all(%Q{
            SELECT column_name, data_type, data_length, char_used, char_length, data_precision, data_scale, data_default, nullable
            FROM all_tab_columns
            WHERE owner = SYS_CONTEXT('userenv', 'current_schema')
            AND table_name = '#{table_name}'
            ORDER BY column_id
          }).map do |row|
              if (v = virtual_columns.find { |col| col['column_name'] == row['column_name'] })
                structure_dump_virtual_column(row, v['data_default'])
              else
                structure_dump_column(row)
              end
            end
            ddl << cols.join(",\n ")
            ddl << structure_dump_primary_key(table_name)
            ddl << "\n)"
            structure << ddl
            structure << structure_dump_indexes(table_name)
            structure << structure_dump_unique_keys(table_name)
          end

          join_with_statement_token(structure) << structure_dump_fk_constraints
        end

        def structure_dump_primary_key(table) #:nodoc:
          opts = {:name => '', :cols => []}
          pks  = select_all(<<-SQL, "Primary Keys")
          SELECT a.constraint_name, a.column_name, a.position
            FROM all_cons_columns a
            JOIN all_constraints c
              ON a.constraint_name = c.constraint_name
           WHERE c.table_name = '#{table.upcase}'
             AND a.owner = SYS_CONTEXT('userenv', 'current_schema')
             AND c.owner = SYS_CONTEXT('userenv', 'current_schema')
             AND c.constraint_type = 'P'
          SQL
          pks.each do |row|
            opts[:name]                    = row['constraint_name']
            opts[:cols][row['position']-1] = row['column_name']
          end
          opts[:cols].length > 0 ? ",\n CONSTRAINT #{opts[:name]} PRIMARY KEY (#{opts[:cols].join(',')})" : ''
        end

        def structure_dump_unique_keys(table) #:nodoc:
          keys = {}
          uks  = select_all(<<-SQL, "Primary Keys")
          SELECT a.constraint_name, a.column_name, a.position
            FROM all_cons_columns a
            JOIN all_constraints c
              ON a.constraint_name = c.constraint_name
           WHERE c.table_name = '#{table.upcase}'
             AND c.constraint_type = 'U'
             AND c.owner = SYS_CONTEXT('userenv', 'current_schema')
          SQL
          uks.each do |uk|
            keys[uk['constraint_name']]                   ||= []
            keys[uk['constraint_name']][uk['position']-1] = uk['column_name']
          end
          keys.map do |k, v|
            "ALTER TABLE #{table.upcase} ADD CONSTRAINT #{k} UNIQUE (#{v.join(',')})"
          end
        end

        def structure_dump_fk_constraints #:nodoc:
          fks = select_all("SELECT table_name FROM all_tables WHERE owner = SYS_CONTEXT('userenv', 'current_schema') ORDER BY 1").map do |table|
            if respond_to?(:foreign_keys) && (foreign_keys = foreign_keys(table["table_name"])).any?
              foreign_keys.map do |fk|
                sql = "ALTER TABLE #{quote_table_name(fk.from_table)} ADD CONSTRAINT #{quote_column_name(fk.options[:name])} "
                sql << "#{foreign_key_definition(fk.to_table, fk.options)}"
              end
            end
          end.flatten.compact
          join_with_statement_token(fks)
        end

        # Extract all stored procedures, packages, synonyms and views.
        def structure_dump_db_stored_code #:nodoc:
          structure = []
          select_all("SELECT DISTINCT name, type
                     FROM all_source
                    WHERE type IN ('PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'FUNCTION', 'TRIGGER', 'TYPE')
                      AND name NOT LIKE 'BIN$%'
                      AND owner = SYS_CONTEXT('userenv', 'current_schema') ORDER BY type").each do |source|
            ddl = "CREATE OR REPLACE   \n"
            select_all(%Q{
                  SELECT text
                    FROM all_source
                   WHERE name = '#{source['name']}'
                     AND type = '#{source['type']}'
                     AND owner = SYS_CONTEXT('userenv', 'current_schema')
                   ORDER BY line
                }).each do |row|
              ddl << row['text']
            end
            ddl << ";" unless ddl.strip[-1, 1] == ';'
            structure << ddl
          end

          # export views
          select_all("SELECT view_name, text FROM all_views WHERE owner = SYS_CONTEXT('userenv', 'current_schema') ORDER BY view_name ASC").each do |view|
            structure << "CREATE OR REPLACE FORCE VIEW #{view['view_name']} AS\n #{view['text']}"
          end

          # export synonyms
          select_all("SELECT owner, synonym_name, table_name, table_owner
                      FROM all_synonyms
                     WHERE owner = SYS_CONTEXT('userenv', 'current_schema') ").each do |synonym|
            structure << "CREATE OR REPLACE #{synonym['owner'] == 'PUBLIC' ? 'PUBLIC' : '' } SYNONYM #{synonym['synonym_name']}
			FOR #{synonym['table_owner']}.#{synonym['table_name']}"
          end

          join_with_statement_token(structure)
        end

        def structure_drop #:nodoc:
          statements = select_values("SELECT sequence_name FROM all_sequences WHERE sequence_owner = SYS_CONTEXT('userenv', 'current_schema') ORDER BY 1").map do |seq|
            "DROP SEQUENCE \"#{seq}\""
          end
          select_values("SELECT table_name from all_tables t
                    WHERE owner = SYS_CONTEXT('userenv', 'current_schema') AND secondary = 'N'
                      AND NOT EXISTS (SELECT mv.mview_name FROM all_mviews mv WHERE mv.owner = t.owner AND mv.mview_name = t.table_name)
                      AND NOT EXISTS (SELECT mvl.log_table FROM all_mview_logs mvl WHERE mvl.log_owner = t.owner AND mvl.log_table = t.table_name)
                    ORDER BY 1").each do |table|
            statements << "DROP TABLE \"#{table}\" CASCADE CONSTRAINTS"
          end
          join_with_statement_token(statements)
        end

        def temp_table_drop #:nodoc:
          join_with_statement_token(select_values(
                                      "SELECT table_name FROM all_tables
                    WHERE owner = SYS_CONTEXT('userenv', 'current_schema') AND secondary = 'N' AND temporary = 'Y' ORDER BY 1").map do |table|
            "DROP TABLE \"#{table}\" CASCADE CONSTRAINTS"
          end)
        end

        # virtual columns are an 11g feature.  This returns [] if feature is not
        # present or none are found.
        # return [{'column_name' => 'FOOS', 'data_default' => '...'}, ...]
        def virtual_columns_for(table)
          begin
            select_all <<-SQL
            SELECT column_name, data_default
              FROM all_tab_cols
             WHERE virtual_column = 'YES'
               AND owner = SYS_CONTEXT('userenv', 'current_schema')
               AND table_name = '#{table.upcase}'
            SQL
              # feature not supported previous to 11g
          rescue ActiveRecord::StatementInvalid => _e
            []
          end
        end

        def drop_sql_for_feature(type)
          short_type = type == 'materialized view' ? 'mview' : type
          join_with_statement_token(
            select_values("SELECT #{short_type}_name FROM all_#{short_type.tableize} WHERE owner=SYS_CONTEXT('userenv', 'current_schema')").map do |name|
              "DROP #{type.upcase} \"#{name}\""
            end)
        end

        def drop_sql_for_object(type)
          join_with_statement_token(
            select_values("SELECT object_name FROM all_objects WHERE object_type = '#{type.upcase}' AND owner=SYS_CONTEXT('userenv', 'current_schema')").map do |name|
              "DROP #{type.upcase} \"#{name}\""
            end)
        end

      end
    end
  end
end

ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.class_eval do
  include ActiveRecord::ConnectionAdapters::OracleEnhanced::CurrentSchemaStructureDump
end
