module GovDelivery
  class Host
    def datacenter
      hostname_parts[-2]
    end

    def env
      hostname_parts[0].split('-')[0] rescue nil
    end

    def hostname_parts
      @parts ||= hostname.strip.split('.')
    end

    def hostname
      `hostname`
    end

  end
end