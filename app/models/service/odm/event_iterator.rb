module Service
  module Odm
    class EventIterator
      include Enumerable
      def initialize(fetcher, sequence, transactor = ActiveRecord::Base.method(:transaction))
        @transactor = transactor
        @fetcher = fetcher
        @sequence = sequence
      end

      def each(&block)
        return self unless block
        begin
          batch = @transactor.call do
            do_batch(block)
          end
        end while (batch.has_more?)
      end

      def do_batch(block)
        # fetcher guarantees batch will conform to contract:
        # Batch = Struct.new(:events -> Enumerable, :next_sequence -> String, :has_more? -> Boolean)
        batch = @fetcher.fetch(@sequence.sequence)
        batch.events.each do |event|
          block.call(event)
        end
        @sequence.update_sequence!(batch.next_sequence)
        batch
      end
    end
  end
end
