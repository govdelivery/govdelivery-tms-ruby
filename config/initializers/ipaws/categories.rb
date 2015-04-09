#
# Initialize IPAWS categories
#

IPAWS::Category.all = [
  IPAWS::Category.new(
    value: 'Geo',
    description: 'Geophysical (inc. landslide)',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Met',
    description: 'Meteorological (inc. flood)',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Safety',
    description: 'General emergency and public safety',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Security',
    description: 'Law enforcement, military, homeland and local/private security',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Rescue',
    description: 'Rescue and recovery',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Fire',
    description: 'Fire suppression and rescue',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Health',
    description: 'Medical and public health',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Env',
    description: 'Pollution and other environmental',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Transport',
    description: 'Public and private transportation',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Infra',
    description: 'Utility, telecommunication, other non-trasport infrastructure',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'CBRNE',
    description: 'Chemical, Biological, Radiological, Nuclear or High-Yield Explosive threat or attack',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::Category.new(
    value: 'Other',
    description: 'Other events',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  )
]
