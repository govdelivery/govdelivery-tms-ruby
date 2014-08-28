RSpec::Matchers.define :be_json_for do |expected|

  chain :with_attributes do |*attributes|
    @attributes = attributes
  end

  chain :with_objects do |*attributes|
    @objects = attributes
  end

  chain :with_arrays do |*attributes|
    @arrays = attributes
  end

  chain :with_timestamps do |*timestamps|
    @timestamps = timestamps
  end

  chain :with_errors do |*timestamps|
    @errors=true
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

    @links      ||= []
    @objects    ||= []
    @arrays     ||= []
    @timestamps ||= [:created_at, :updated_at]
    fail('no attributes specified') unless @attributes

    json.each do |k, v|
      if k=='errors' && @errors
        v.should be_a(Array)
      elsif k=='_links'
        @links.each { |rel, href| v[rel.to_s].should eq(href) }
        @links.keys.length.should eq(v.keys.length)
      elsif ts=@timestamps.delete(k.to_sym)
        Time.parse(v).to_s(:json).should eq(expected.send(ts).to_s(:json))
      elsif @objects.delete(k.to_sym)
        v.should be_a(Hash)
      elsif @arrays.delete(k.to_sym)
        v.should be_a(Array)
      elsif @attributes.delete(k.to_sym)
        v.should eq(expected.send(k))
      else
        fail("Unrecognized JSON attribute #{k}: #{rendered}")
      end
    end
    all_attrs = @timestamps + @attributes + @objects
    fail("Did not find attributes #{all_attrs.join(', ')} in #{json}") unless all_attrs.empty?
    true
  end
end

