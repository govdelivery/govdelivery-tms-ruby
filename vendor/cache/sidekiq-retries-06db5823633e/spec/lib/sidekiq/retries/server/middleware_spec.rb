require 'spec_helper'
require 'sidekiq/api'

module Sidekiq
  module Retries
    module Server
      class RetryWorker
        include Sidekiq::Worker
      end

      describe Middleware do
        let (:handler) { Sidekiq::Retries::Server::Middleware.new }
        let (:queue) { 'default' }
        let (:errmsg) { 'oh man what did you do' }

        before do
          Sidekiq::RetrySet.new.clear
        end

        context 'a worker without retry' do
          it 'should retry anyway if we raise a Sidekiq::Retries::Retry' do
            args = {'class' => 'Bob',
                    'args' => [1],
                    'retry' => false}
            expect {
              handler.call(RetryWorker, args, queue) do
                raise Sidekiq::Retries::Retry.new(RuntimeError.new(errmsg), 10)
              end
            }.to raise_error(RuntimeError, errmsg)
            expect(Sidekiq::RetrySet.new.size).to eq(1)
          end

        end

        context 'a worker with retry' do
          it 'should not retry if we raise a Sidekiq::Retries::Fail' do
            args = {'class' => 'Bob',
                    'args' => [1],
                    'retry' => 2}
            expect {
              handler.call(RetryWorker, args, queue) do
                raise Sidekiq::Retries::Fail.new(RuntimeError.new(errmsg))
              end
            }.to raise_error(RuntimeError, errmsg)

            expect(Sidekiq::RetrySet.new.size).to eq(0)
          end
        end

      end
    end
  end
end