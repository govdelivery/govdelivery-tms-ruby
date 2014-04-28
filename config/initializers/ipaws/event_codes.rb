#
# Initialize IPAWS static resources
#

IPAWS::EventCode.all = [
  IPAWS::EventCode.new(
    value: 'ADR',
    description: 'Administrative Message/Follow up Statement',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'AVA',
    description: 'Avalanche Watch',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'AVW',
    description: 'Avalance Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'BZW',
    description: 'Blizzard Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'CAE',
    description: 'Child Abduction Emergency',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'CDW',
    description: 'Civil Danger Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'CEM',
    description: 'Civil Emergency Message',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'CFW',
    description: 'Coastal Flood Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'DMO',
    description: 'Practice/Demo Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'DSW',
    description: 'Dust Storm Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'EAN',
    description: 'Presidential Alert',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'EQW',
    description: 'Earthquake Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'EVI',
    description: 'Evacuation Immediate',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'FFW',
    description: 'Flash Flood Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'FRW',
    description: 'Fire Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'HMW',
    description: 'Hazardous Materials Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'HUW',
    description: 'Hurricane Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'HWW',
    description: 'High Wind Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'LEW',
    description: 'Law Enforcement Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'LAE',
    description: 'Local Area Emergency',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'NIC',
    description: 'National Information Center',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'NMN',
    description: 'Network Message Notification',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'NPT',
    description: 'National Periodic Test',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'NUW',
    description: 'Nuclear Power Plant Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'RHW',
    description: 'Radiological Hazard Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'RMT',
    description: 'Required Monthly Test',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'RWT',
    description: 'Required Weekly Test',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'SPW',
    description: 'Shelter in Place Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'SVR',
    description: 'Severe Thunderstorm Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'SMW',
    description: 'Special Marine Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'TOE',
    description: '911 Telephone Outage Emergency',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: false
  ),
  IPAWS::EventCode.new(
    value: 'TOR',
    description: 'Tornado Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'TRW',
    description: 'Tropical Storm Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'TSW',
    description: 'Tsunami Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'VOW',
    description: 'Volcano Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: true,
    eas_and_public: true,
    cmas: true
  ),
  IPAWS::EventCode.new(
    value: 'WSW',
    description: 'Winter Storm Warning',
    cap_exchange: true,
    core_ipaws_profile: true,
    nwem: false,
    eas_and_public: true,
    cmas: true
  )
]





