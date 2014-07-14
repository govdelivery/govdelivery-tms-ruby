module Analytics
  class Supervisor < Celluloid::SupervisionGroup
    POOL_SIZE = 2

    pool ClickListener, as: :click_listener_pool, size: POOL_SIZE
    pool OpenListener,  as: :open_listener_pool, size: POOL_SIZE

    def self.go!
      self.run!
      POOL_SIZE.times do |f|
        Celluloid::Actor[:open_listener_pool].async.listen
        Celluloid::Actor[:click_listener_pool].async.listen
      end
    end
  end
end