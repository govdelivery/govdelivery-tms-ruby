bundle update ––source tms_client
export RAILS_ENV=ci
bundle exec sidekiq &
export SIDEKIQ_PID=$!
rake test:integration:run