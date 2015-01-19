#!/usr/bin/env ruby
require 'optparse'

class CreateVendor
  def run_from_options(argv)
    parse_options(argv)
    boot_rails
    if(@options[:list])
      list_vendors()
    elsif(@options[:vendor_type] == "SmsVendor")
      create_sms_vendor(@options)
    elsif(@options[:vendor_type] == "VoiceVendor")
      create_voice_vendor(@options)
    elsif(@options[:vendor_type] == "EmailVendor")
      create_email_vendor(@options)
    elsif(@options[:vendor_type] == "IPAWSVendor")
      create_ipaws_vendor(@options)
    else
      puts "Incorrect Vendor type. see --help"
    end
  end

  def boot_rails
    require File.expand_path("../../config/environment", __FILE__)
  end

  def parse_options(argv)
    argv[0] = '--help' unless argv[0]
    @options = {}
    OptionParser.new do |opts|
      opts.banner = <<-USAGE
Usage:
  #{__FILE__} [options]

Examples:

  List All Vendors
    #{__FILE__} -l

  Create Sms Vendor
    #{__FILE__} -t SmsVendor -n "INSURE Short Code" -u "ACcc41a7e742457806f26d91a1ea19de9f" -p "331b3a44b5067a3c02013a6cfaa18b1c" -f "467873" -w "TwilioMessageWorker" -h "Visit Help@govdelivery.com for help or more at 800-314-0147. Reply STOP to cancel. Msg&Data rates may apply. 5msgs/month." -s "You are opted out from Medicare Alerts. No more messages will be sent. Reply HELP for help or Help@govdelivery.com. Msg&Data rates may apply."

  Create Voice Vendor
    #{__FILE__} -t VoiceVendor -n "651-433-6258" -u "ACcc41a7e742457806f26d91a1ea19de9f" -p "331b3a44b5067a3c02013a6cfaa18b1c" -f "651-433-6258" -w "TwilioVoiceWorker"

  Create Email Vendor
    #{__FILE__} -t EmailVendor -n "ODM" -w "Odm::TmsExtendedSenderWorker"

  Create IPAWS Vendor
    #{__FILE__} -t IPAWSVendor -c 120082 -u "IPAWSOPEN_120082" -p "w0rk#8980" -r "2670soa#wRn" -j /path/to/file.jks

Options:
USAGE
      opts.on("-l", "--list", "List all Vendors") do |p|
        @options[:list] = p
      end
      opts.on("-t", "--type Vendor Type") do |p|
        @options[:vendor_type] = p.to_s
      end
      opts.on("-n", "--name Vendor Name") do |p|
        @options[:vendor_name] = p.to_s
      end
      opts.on("-u", "--username Vendor User Name") do |p|
        @options[:vendor_username] = p.to_s
      end
      opts.on("-p", "--password Vendor Password") do |p|
        @options[:vendor_password] = p.to_s
      end
      opts.on("-f", "--from Vendor From") do |p|
        @options[:vendor_from] = p.to_s
      end
      opts.on("-w", "--worker Vendor Worker") do |p|
        @options[:vendor_worker] = p.to_s
      end
      opts.on("-h", "--help_text Vendor Help Text") do |p|
        @options[:vendor_help_text] = p.to_s
      end
      opts.on("-s", "--stop_text Vendor Stop Text") do |p|
        @options[:vendor_stop_text] = p.to_s
      end
      opts.on("-S", "--start_text Vendor Start Text") do |p|
        @options[:vendor_start_text] = p.to_s
      end
      opts.on("-a", "--shared", "Indicate if this SMS vendor is shared or exclusive.  If you pass this argument, the SMS vendor will be shared.") do |p|
        @options[:shared] = true
      end
      opts.on("-c", "--cog-id IPAWS::Vendor COG ID") do |p|
        @options[:vendor_cog_id] = p.to_s
      end
      opts.on("-r", "--private-password IPAWS::Vendor private password") do |p|
        @options[:vendor_private_password] = p.to_s
      end
      opts.on("-j", "--jks IPAWS::Vendor JKS file") do |p|
        @options[:vendor_jks_file] = p.to_s
      end

    end.parse!(argv)
  end

  def out(str)
    puts(str) unless RAILS_ENV == 'test'
  end

  def create_sms_vendor(options)

    v = SmsVendor.new
    v.name = @options[:vendor_name]
    v.username = @options[:vendor_username]
    v.password = @options[:vendor_password]
    v.from_phone = @options[:vendor_from]
    v.worker = @options[:vendor_worker]
    v.help_text = @options[:vendor_help_text]
    v.stop_text = @options[:vendor_stop_text]
    v.start_text = @options[:vendor_start_text]
    v.shared = !!@options[:shared]

    v.save

    if(v.errors)
      puts v.errors.messages
    else
      puts "Created SmsVendor id: " + v.id.to_s
    end

  end

  def create_voice_vendor(options)

    v = VoiceVendor.new
    v.name = @options[:vendor_name]
    v.username = @options[:vendor_username]
    v.password = @options[:vendor_password]
    v.from_phone = @options[:vendor_from]
    v.worker = @options[:vendor_worker]

    v.save

    if(v.errors)
      puts v.errors.messages
    else
      puts "Created VoiceVendor id: " + v.id.to_s
    end

  end

  def create_email_vendor(options)

    v = EmailVendor.new
    v.name = @options[:vendor_name]
    v.worker = @options[:vendor_worker]

    v.save

    if(v.errors)
      puts v.errors.messages
    else
      puts "Created EmailVendor id: " + v.id.to_s
    end

  end

  def create_ipaws_vendor(options)
    v = IPAWS::Vendor.new()
    v.cog_id = options[:vendor_cog_id]
    v.user_id = options[:vendor_username]
    v.public_password = options[:vendor_password]
    v.private_password = options[:vendor_private_password]
    v.jks = File.binread(options[:vendor_jks_file])
    if v.save
      puts "Created IPAWS::Vendor id: #{v.id}"
    else
      puts v.errors.full_messages
    end
  end

  def list_vendors

    puts "SmsVendor.all\n";
    SmsVendor.all.each { |v|
      puts "\tid: " + v.id.to_s + "\n"
      puts "\tname: " + v.name + "\n"
      puts "\tfrom_phone: " + v.from_phone.to_s + "\n"
      puts "\tshared: " + v.shared.to_s + "\n"
      puts "\n"
    }

    puts "VoiceVendor.all\n";
    VoiceVendor.all.each { |v|
      puts "\tid: " + v.id.to_s + "\n"
      puts "\tname: " + v.name + "\n"
      #puts "\tfrom_phone: " + v.from_phone.to_s + "\n"
      puts "\n"
    }

    puts "EmailVendor.all\n";
    EmailVendor.all.each { |v|
      puts "\tid: " + v.id.to_s + "\n"
      puts "\tname: " + v.name + "\n"
      puts "\tworker: " + v.worker.to_s + "\n"
      puts "\n"
    }

  end

end



if __FILE__ == $0
  CreateVendor.new.run_from_options(ARGV)
end

