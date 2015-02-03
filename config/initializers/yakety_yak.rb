if (conf = Rails.configuration.analytics) && conf[:enabled]

  YaketyYak.configure do |y|
    y.kafkas     = conf[:kafkas]
    y.zookeepers = conf[:zookeepers]
  end

  YaketyYak.logger = Rails.logger

  require Rails.root.join('app/workers/analytics/click_listener')
  require Rails.root.join('app/workers/analytics/open_listener')
end
