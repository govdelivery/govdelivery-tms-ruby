class SerializeExistingActionParameters < ActiveRecord::Migration
  def up
    # :params => ActionParameters.new(:dcm_account_codes => ["ACCOUNT_1", "ACCOUNT_2"])
    # :params => ActionParameters.new(:dcm_account_code => ["ACCOUNT_1"], :dcm_topic_codes => ["TOPIC_1", "TOPIC_2"])
    # :params => ActionParameters.new(:http_method => "POST|GET", :username => "foo", :password => "bar", :url => "https://foobar.com")
    Action.where(:action_type => :dcm_unsubscribe).each do |a|
      unless a.params.is_a? ActionParameters
        ap = ActionParameters.new(:dcm_account_codes => a.params.split(','))
        a.params = ap
        a.save!
      end
    end

    Action.where(:action_type => :dcm_subscribe).each do |a|
      unless a.params.is_a? ActionParameters
        ap = ActionParameters.new(parse_dcm_subscribe_params(a.params))
        a.params = ap
        a.save!
      end
    end

    Action.where(:action_type => :forward).each do |a|
      unless a.params.is_a? ActionParameters
        ap = ActionParameters.new(parse_forward_params(a.params))
        a.params = ap
        a.save!
      end
    end
  end

  # account_code:topic1,topic2,topic3
  def parse_dcm_subscribe_params(str)
    account_code, topics = str.split(':')
    {:dcm_account_code => account_code, :dcm_topic_codes => topics.split(',')}
  end

  # POST http://foo.com
  def parse_forward_params(str)
    http_method, action = str.split(/\s/)
    {:http_method => http_method, :url => action}
  end

  def down
  end
end
