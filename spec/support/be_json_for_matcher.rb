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

  chain :with_errors do |*_timestamps|
    @errors = true
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

    @links ||= []
    @objects ||= []
    @arrays ||= []
    @timestamps ||= [:created_at, :updated_at]
    raise('no attributes specified') unless @attributes

    raise('expected _links') if @links.present? && !json.key?('_links')

    json.each do |k, v|
      if k == 'errors' && @errors
        expect(v).to be_a(Hash)
      elsif k == '_links'
        @links.each { |rel, href| expect(v[rel.to_s]).to eq(href) }
        expect(@links.keys.length).to eq(v.keys.length)
      elsif ts = @timestamps.delete(k.to_sym)
        expect(Time.zone.parse(v).to_s(:json)).to eq(expected.send(ts).to_s(:json))
      elsif @objects.delete(k.to_sym)
        expect(v).to be_a(Hash)
      elsif @arrays.delete(k.to_sym)
        expect(v).to be_a(Array)
      elsif @attributes.delete(k.to_sym)
        expect(v).to eq(expected.send(k))
      else
        raise("Unrecognized JSON attribute #{k}: #{rendered}")
      end
    end
    all_attrs = @timestamps + @attributes + @objects
    raise("Did not find attributes #{all_attrs.join(', ')} in #{json}") unless all_attrs.empty?
    true
  end
end
