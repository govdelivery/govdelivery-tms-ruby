RSpec::Matchers.define :be_json_for do |expected|

  chain :with_attributes do |*attributes|
    @attributes = attributes
  end

  chain :with_timestamps do |*timestamps|
    @timestamps = timestamps
    @timestamps = [:created_at, :updated_at] if @timestamps.compact.empty?
  end

  chain :with_links do |links|
    @links = links
  end

  # e.g.
  # rendered.should be_json_for(expected_obj).
  #                   with_attributes(:first_name, :last_name).
  #                   with_timestamps.with_links(:self=>'/messages/1')
  match do |actual|
    json = ActiveSupport::JSON.decode(actual)

    json.each do |k, v|
      if k=='_links'
        @links.each { |rel, href| v[rel.to_s].should eq(href) }
        @links.keys.length.should eq(v.keys.length)
      elsif @timestamps.include?(k.to_sym)
        Time.parse(v).to_s(:json).should eq(expected.send(k).to_s(:json))
      elsif @attributes.include?(k.to_sym)
        v.should eq(expected.send(k))
      else
        fail("Unrecognized JSON attribute #{k}: #{rendered}")
      end
    end
  end
end

