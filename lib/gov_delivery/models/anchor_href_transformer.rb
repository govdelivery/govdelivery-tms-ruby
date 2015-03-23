####################################
# Totally copied and pasted from Evo
####################################

# This utility will remove any leading and/or trailing white spaces or url encoded spaces %20
# from any matched anchor href urls.
# If an account has any link tracking parameters, they'll be appended to the href, e.g.
#   <a href="[VALUE]"> with <a href="[VALUE]?key=value&amp;key2=value2">
# Note that urls not within an anchor tag are not modified.
require 'addressable/uri'
class AnchorHrefTransformer

  URL_ENCODED_SPACE = '%20'
  DEFAULT_SEP       = /[&;] */n
  KEY_SPACE_LIMIT   = 65536

  # This pattern should be functionally equivalent to the pattern
  # used in https://svn.office.gdi/development/GovDelivery/src/com/govdelivery/mail/SubscriberMailer.java
  # to ensure GD2 compatibility
  # Note: this is how you could get ALL urls in a string, in case it
  # becomes necessary
  # URI::extract(text, ["http", "https"])
  ANCHOR_TAG_REGEXP = /(<A[^>]*?HREF\s*=\s*[\"']?)((?:\s|%20)*http[^'\"]+)([^>]*>)/ium

  module UtilityFunctions
    def querystring_to_hash(uri)
      Rack::Utils.parse_query(parse_url(uri).query)
    end

    def parse_url(url)
      Addressable::URI.parse(unescaped(url))
    end

    def unescaped(url)
      CGI.unescapeHTML(url).gsub(URL_ENCODED_SPACE, ' ')
    end
  end

  extend UtilityFunctions
  include UtilityFunctions

  attr_accessor :tracking_parameters

  def initialize(tracking_parameters)
    self.tracking_parameters = tracking_parameters
  end

  # removing any leading trailing whites spaces and/or %20s from href url
  # add tracking params to querystring if there are any
  def replace_all_hrefs(text)
    self.unique_anchor_links(text).each do |(open, url, rest)|
      new_url    = url.strip.gsub(/^(#{URL_ENCODED_SPACE})+/, '').gsub(/(#{URL_ENCODED_SPACE})+$/, '')
      parsed_url = parse_url(new_url)
      if tracking_parameters.any? && !(parsed_url.host =~ /govdelivery\.com/)
        new_url = modify_href(parsed_url, tracking_parameters).to_s
      end
      if url != new_url
        text = text.gsub([open, url, rest].join, [open, new_url, rest].join)
      end
    end
    text
  end

  # Given a URI::HTTP instance, add tracking params to it (and all urls encoded as query string params)
  def modify_href(uri, tracking_parameters)
    query = Rack::Utils.parse_query(uri.query)
    query.each do |k, v|
      query[k] = modify_href(parse_url(v), tracking_parameters).to_s if v && is_uri?(v)
    end
    tracking_parameters.each { |key, value| query[key] = value }
    uri.query = query.to_query # This will implicitly do a CGI.escape on each value
    uri
  end

  # Input is a URI-escaped query string value
  def is_uri?(str)
    unescaped(str) =~ ValidatesUrlFormatOf::REGEXP
  rescue Encoding::CompatibilityError => e
    return false
  end

  # Get a unique list of the urls found in the text
  # in three parts: [['<a href="', 'http://somewhere.com', '>'], [...]]
  def unique_anchor_links(text)
    text.scan(ANCHOR_TAG_REGEXP).uniq
  end
end
