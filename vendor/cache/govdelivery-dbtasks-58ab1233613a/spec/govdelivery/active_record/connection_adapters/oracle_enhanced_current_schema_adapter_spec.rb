require 'spec_helper'

describe ActiveRecord::ConnectionAdapters::OracleEnhancedCurrentSchemaAdapter do
  subject { ActiveRecord::Migration.new }
  let(:pool) { subject.class.connection_pool }

  before do
    ActiveRecord::Base.configurations = YAML.load_file('spec/database.yml')
  end

  context 'a connection without schema specified' do
    let(:conn) {ActiveRecord::Base.connection}
    before do
      ActiveRecord::Base.establish_connection('example_without_schema')
    end
    after do
      conn.close
    end

    it 'should implement oracle_enhanced_connection and schema_owner (:username)' do
      expect(conn.oracle_enhanced_connection).to be_a ActiveRecord::ConnectionAdapters::OracleEnhancedConnection
      expect(conn.oracle_enhanced_connection.owner).to eq ActiveRecord::Base.connection_config[:username].upcase
      expect(conn.schema_owner).to eq conn.oracle_enhanced_connection.owner
    end
  end

  context 'a connection with schema specified' do
    before do
      ActiveRecord::Migration.env = 'development'
    end

    after do
      ActiveRecord::Migration.env = nil
    end

    it 'should implement oracle_enhanced_connection and schema_owner (:schema)' do
      pool.with_connection do |conn|
        expect(conn.oracle_enhanced_connection).to be_a ActiveRecord::ConnectionAdapters::OracleEnhancedConnection
        expect(conn.oracle_enhanced_connection.owner).to eq conn.oracle_enhanced_connection.config[:schema].upcase
        expect(conn.schema_owner).to eq conn.oracle_enhanced_connection.owner
      end
    end

    context "initialize_schema_migrations_table" do
      before do
        begin
          pool.with_connection do |conn|
            conn.drop_table('schema_migrations')
          end
        rescue => e
          warn "setup error while dropping schema_migration: #{e.message}"
        end
      end
      it 'should work' do
        pool.with_connection do |conn|
          expect { conn.initialize_schema_migrations_table }.to_not raise_error
        end
      end
    end

    context "schema dumper methods" do
      before do
        schema_define do
          create_table :temps, temporary: true, force: true do |t|
            t.integer :thing3
          end

          create_table :foreigners, force: true do |t|
            t.integer :thing4
          end

          create_table :foos, force: true do |t|
            t.integer :thing1
            t.references :foreigner
          end

          add_foreign_key "foos", "foreigners", name: "foo_fors", dependent: :delete
        end
      end

      after do
        schema_define do
          drop_table :temps, cascade: true
          drop_table :foos, cascade: true
          drop_table :foreigners, cascade: true
        end
      end

      it "should recognize temp tables" do
        pool.with_connection do |conn|
          expect(conn.temporary_table?('temps')).to be true
          expect(conn.foreign_keys('foos').first.to_table).to eq 'foreigners'
        end
      end
    end

  end
end
