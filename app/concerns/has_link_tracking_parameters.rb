require 'active_support'

module HasLinkTrackingParameters
  ##
  # Make link tracking parameters act just like they do in Evo
  #
  def link_tracking_parameters_hash
    GovDelivery::Links::Transformer.querystring_to_hash('?' + (link_tracking_parameters || ''))
  end
end
