#
# Initialize IPAWS response types
#

IPAWS::ResponseType.all = [
  IPAWS::ResponseType.new(
    value: 'Shelter',
    description: 'Take shelter in place or per CAP Alert <instruction> element',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::ResponseType.new(
    value: 'Evacuate',
    description: 'Relocate as instructed in the CAP Alert <instruction> element',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::ResponseType.new(
    value: 'Prepare',
    description: 'Make preparations per the CAP Alert <instruction> element',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::ResponseType.new(
    value: 'Execute',
    description: 'Execute a pre-planned activity identified in CAP Alert <instruction> element',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::ResponseType.new(
    value: 'Avoid',
    description: 'Avoid the subject event as per the CAP Alert <instruction> element',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::ResponseType.new(
    value: 'Monitor',
    description: 'Attend to information sources as described in CAP Alert <instruction> element',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::ResponseType.new(
    value: 'Assess',
    description: 'Evaluate the information in this message. (This value SHOULD NOT be used in public warning applications.)',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::ResponseType.new(
    value: 'AllClear',
    description: 'The subject event no longer poses a threat or concern and any follow on action is described in CAP Alert <instruction> element',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::ResponseType.new(
    value: 'None',
    description: 'No action recommended',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: nil,
    eas_and_public: true,
    cmas: false
  )
]