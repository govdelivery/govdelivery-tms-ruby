# Change Log
All notable changes to this project will be documented in this file, as
suggested by [How to use a CHANGELOG](http://keepachangelog.com/).

This project *does not* adhere to [Semantic Versioning](http://semver.org/).

## [2.8.3]
### Changed
- Move from random point version releases and tie gem version to the version of [TMS](https://tms.govdelivery.com/.version).

## [0.10.1]
### Added
- Replaced ActiveSupport::Inflector.camelize with custom version that does not use acronyms.

## [0.10.0]
### Added
- `from_name` attribute on FromAddress resource, mirroring changes to the TMS API

### Fixed
- Removed ability to POST or PUT to the from_address endpoint, as this feature
  is not supported by the TMS API
- Pinned mime-types dependency to a version that supports jRuby
