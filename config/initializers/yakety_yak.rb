if Rails.configuration.analytics[:enabled]
  conf = Rails.configuration.analytics

  YaketyYak.configure do |y|
    y.kafkas     = conf['kafkas']
    y.zookeepers = conf['zookeepers']
    y.group_id   = conf['group_id']
  end

  YaketyYak.logger = Rails.logger
end