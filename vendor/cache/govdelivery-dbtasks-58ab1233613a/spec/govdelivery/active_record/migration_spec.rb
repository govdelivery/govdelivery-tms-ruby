require 'spec_helper'

describe ActiveRecord::Migration do
  subject { ActiveRecord::Migration.new }

  context 'a connection by environment' do
    before do
      ActiveRecord::Migration.env       = nil
      ActiveRecord::Base.configurations = YAML.load_file('spec/database.yml')
    end

    it 'should set env upon connecting' do
      ActiveRecord::Migration.env = 'example'
      subject.connection
      expect(subject.class.env).to eq 'example'
    end

    after do
      ActiveRecord::Migration.env = nil
    end
  end

  context 'a connection with schema specified' do
    before do
      ActiveRecord::Migration.env = 'example_with_invalid_oper_password'

      ActiveRecord::Base.configurations = YAML.load_file('spec/database.yml')
    end

    it 'should connect as migrator user using ActiveRecord::Migration.connection' do
      fail('No development specified in database.yml') unless ActiveRecord::Base.configurations['development']
      fail('No development schema owner specified in database.yml') unless ActiveRecord::Base.configurations['development']['migration_username']

      connection = subject.connection
      owner      = connection.select_one("select sys_context( 'userenv', 'current_schema' ) as current_schema from dual")['current_schema']
      username   = connection.select_one("select sys_context( 'userenv', 'current_user' ) as current_schema from dual")['current_schema']
      expect(owner).to eq(ActiveRecord::Base.configurations['development']['schema'].upcase)
      expect(username).to eq(ActiveRecord::Base.configurations['development']['migration_username'].upcase)
      expect(owner).to_not eq(username)
    end

    it 'should expose raw connection' do
      expect(subject.oracle_enhanced_connection).to be_a(ActiveRecord::ConnectionAdapters::OracleEnhancedConnection)
    end

    it 'should allow CommandRecord to be used' do
      recorder = ActiveRecord::Migration::CommandRecorder.new(nil)
      subject.instance_variable_set(:@connection, recorder)
      expect(subject.connection).to eq(recorder)
    end
  end

  describe '#migrate' do
    class MigrateTest < ActiveRecord::Migration
      attr_accessor :connection_used_during_migrate
      def change
        self.connection_used_during_migrate = connection
      end
    end
    subject do
      MigrateTest.new
    end
    it 'uses ActiveRecord::Migration.connection' do
      subject.migrate(:up)
      expect(subject.connection_used_during_migrate).to be subject.connection
    end
  end
end
