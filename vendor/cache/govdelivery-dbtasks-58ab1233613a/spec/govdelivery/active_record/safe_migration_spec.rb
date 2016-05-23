require 'spec_helper'

describe ActiveRecord::SafeMigration do
  module FakeConnection
    def add_index(*)
      execute
    end

    def add_column(*)
      execute
    end

    def add_foreign_key(*)
      execute
    end

    def say(*args)
    end

    def execute
    end
  end

  class FakeMigration
    include FakeConnection
    include ActiveRecord::SafeMigration

    cattr_accessor :env do
      ActiveSupport::StringInquirer.new('development')
    end
  end

  subject { FakeMigration.new }

  before do
    @oldstoud = $stdout.dup
    @oldsterr = $stderr.dup
    $stdout   = $stderr = StringIO.new
  end

  after do
    $stdout = @oldstoud
    $stderr = @oldsterr
  end

  it 'test_add_index_happy' do
    expect(subject).to receive(:execute).and_return(true)
    expect { subject.add_index :foo, [:bar, :baz] }.to_not raise_error
  end

  it 'test_add_index_trapped_exception' do
    # ORA-01408 or ORA-00955
    expect(subject).to receive(:execute).and_raise("already exists")
    expect { subject.add_index :foo, [:bar, :baz] }.to_not raise_error
  end

  it 'test_add_index_untrapped_exception' do
    expect(subject).to receive(:execute).and_raise("something else")
    expect { subject.add_index :foo, [:bar, :baz] }.to raise_error(RuntimeError)
  end

  it 'test_add_column_happy' do
    expect(subject).to receive(:execute).and_return(true)
    expect { subject.add_column :foo, [:bar, :baz] }.to_not raise_error
  end

  it 'test_add_column_trapped_exception' do
    expect(subject).to receive(:execute).and_raise("ORA-01430")
    expect { subject.add_column :foo, [:bar, :baz] }.to_not raise_error(RuntimeError)
  end

  it 'test_add_column_untrapped_exception' do
    expect(subject).to receive(:execute).and_raise("ORA-NOTAREALONE")
    expect { subject.add_column :foo, [:bar, :baz] }.to raise_error(RuntimeError)
  end

  it 'test_add_foreign_key_trapped_exception' do
    expect(subject).to receive(:execute).and_raise("ORA-02275")
    expect { subject.add_foreign_key(:foo, :bar) }.to_not raise_error(RuntimeError)
  end

  it 'test_add_foreign_key_untrapped_exception' do
    expect(subject).to receive(:execute).and_raise("ERROR")
    expect { subject.add_foreign_key(:foo, :bar) }.to raise_error(RuntimeError)
  end
end