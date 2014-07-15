if Rails.configuration.analytics[:enabled]
  conf = Rails.configuration.analytics

  YaketyYak.configure do |y|
    y.kafkas     = conf['kafkas']
    y.zookeepers = conf['zookeepers']
  end

  YaketyYak.logger = Rails.logger
end