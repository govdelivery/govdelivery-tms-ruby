require 'active_record/connection_adapters/abstract/connection_pool'

module ActiveRecord
  module ConnectionAdapters
    class ConnectionPool

      #
      # log the string and a stack trace afterwards
      #
      def log(str)
        Rails.logger.info("#{self.class}: #{str}")
      end

      # Check-in a database connection back into the pool, indicating that you
      # no longer need this connection.
      #
      # +conn+: an AbstractAdapter object, which was obtained by earlier by
      # calling +checkout+ on this pool.
      def checkin(conn)
        synchronize do
          conn.run_callbacks :checkin do
            conn.expire
            @queue.signal
          end

          release conn
          log("checkin: released #{conn.object_id}")
        end
      end

      # Check-out a database connection from the pool, indicating that you want
      # to use it. You should call #checkin when you no longer need this.
      #
      # This is done by either returning an existing connection, or by creating
      # a new connection. If the maximum number of connections for this pool has
      # already been reached, but the pool is empty (i.e. they're all being used),
      # then this method will wait until a thread has checked in a connection.
      # The wait time is bounded however: if no connection can be checked out
      # within the timeout specified for this pool, then a ConnectionTimeoutError
      # exception will be raised.
      #
      # Returns: an AbstractAdapter object.
      #
      # Raises:
      # - ConnectionTimeoutError: no connection can be obtained from the pool
      #   within the timeout period.
      def checkout
        synchronize do
          log("checkout: starting checkout")
          waited_time = 0

          loop do
            log("checkout: searching for an available connection")
            conn = @connections.find do |c| 
              log("checkout: Connection #{c.object_id}")
              log("-- open transactions:          #{c.open_transactions}")
              log("-- in use:                     #{c.in_use}")
              log("-- raw connection:             #{c.raw_connection}")
              log("-- raw connection usable?      #{c.raw_connection.usable?}")
              log("-- raw connection properties   #{c.raw_connection.properties.inspect}")
              log("-- raw connection pingDatabase #{c.raw_connection.pingDatabase}")
              log("------ (see http://docs.oracle.com/cd/E18283_01/appdev.112/e13995/oracle/jdbc/OracleConnection.html)")
              c.lease
            end

            unless conn
              if @connections.size < @size
                log("checkout: checking out new connection")
                conn = checkout_new_connection
                conn.lease
              end
            end

            if conn
              log("checkout: got connection #{conn.object_id}")
              checkout_and_verify conn
              return conn
            else 
              log("checkout: no connection could be obtained")
            end

            if waited_time >= @timeout
              raise ConnectionTimeoutError, "could not obtain a database connection#{" within #{@timeout} seconds" if @timeout} (waited #{waited_time} seconds). The max pool size is currently #{@size}; consider increasing it."
            end

            # Sometimes our wait can end because a connection is available,
            # but another thread can snatch it up first. If timeout hasn't
            # passed but no connection is avail, looks like that happened --
            # loop and wait again, for the time remaining on our timeout. 
            before_wait = Time.now
            log("checkout: about to wait / release lock")
            @queue.wait( [@timeout - waited_time, 0].max )
            waited_time += (Time.now - before_wait)

            # Will go away in Rails 4, when we don't clean up
            # after leaked connections automatically anymore. Right now, clean
            # up after we've returned from a 'wait' if it looks like it's
            # needed, then loop and try again. 
            if(active_connections.size >= @connections.size)
              log("checkout: clearing stale cached connections")
              clear_stale_cached_connections!
            end
          end
        end
      end
    end
  end
end