require 'spec_helper'

describe ActiveRecord::ConnectionAdapters::OracleEnhancedConnection do
  context 'connecting as example' do
    let(:config) { YAML.load_file('spec/database.yml')['example'].symbolize_keys }
    let(:connection) { connection = ActiveRecord::ConnectionAdapters::OracleEnhancedConnection.get_connection(config) }

    it 'should work' do
      fail("invalid database.yml: #{config} should have :schema") unless config[:schema]
      owner    = connection.select_one("select sys_context( 'userenv', 'current_schema' ) as current_schema from dual")['current_schema']
      username = connection.select_one("select sys_context( 'userenv', 'current_user' ) as current_schema from dual")['current_schema']
      expect(owner).to eq(config[:schema].upcase)
      expect(username).to eq(config[:username].upcase)
      expect(connection.owner).to eq owner
      expect(connection.username).to eq username
      expect(owner).to_not eq(username)
      expect(connection.different_schema_owner?).to be true
    end
  end

  context 'connecting as example_without_schema' do
      let(:config) { YAML.load_file('spec/database.yml')['example_without_schema'].symbolize_keys }
      let(:connection) { connection = ActiveRecord::ConnectionAdapters::OracleEnhancedConnection.get_connection(config) }

      it 'should work' do
        fail("invalid database.yml: #{config} shouldn't have :schema") if config[:schema]
        owner    = connection.select_one("select sys_context( 'userenv', 'current_schema' ) as current_schema from dual")['current_schema']
        username = connection.select_one("select sys_context( 'userenv', 'current_user' ) as current_schema from dual")['current_schema']
        expect(owner).to eq(config[:username].upcase)
        expect(username).to eq(config[:username].upcase)
        expect(connection.owner).to eq owner
        expect(connection.username).to eq username
        expect(connection.different_schema_owner?).to be false
      end
    end
end