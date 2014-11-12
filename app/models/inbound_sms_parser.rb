module InboundSmsParser

  module_function

  def parse sms_body, vendor
    san_string = sanitize_string(sms_body)
    account_id = find_account_id(san_string.split.first,vendor)
    prefix, rest = extract_prefix(san_string, vendor)
    keyword_service, message = extract_keyword(rest, vendor, account_id)
    ParsedSms.new [prefix, keyword_service, message, account_id]
  end


  def sanitize_string s
    Keyword.sanitize_string(s)
  end

  def find_account_id first_word, vendor
    if vendor.shared?
      first_word.present? ? vendor.sms_prefixes.account_id_for_prefix(first_word) : nil
    else
      # wow this feels dangerous, private vendors are not enforced
      # TODO: validate private vendor has one or zero accounts in vendor
      # nil might resolve to a help, stop or default on the vendor
      vendor.accounts.first.try(:id)
    end
  end

  # returns [nil, full string] or [prefix, partial string, account_id]
  # the prefix determines the account
  def extract_prefix s, vendor
    first_word, *rest = s.split
    if first_word.present? && vendor.sms_prefixes.account_id_for_prefix(first_word)
      [first_word, rest.join(' ')]
    else
      [nil, s]
    end
  end

  # returns [nil, message, nil] or [keyword, message, account_id]
  def extract_keyword(s, vendor, account_id)
    first_word, *rest = s.split
    keyword_service = Service::Keyword.new(first_word, account_id, vendor)
    if keyword_service.default?
      [keyword_service, s, account_id] #return the full string, no keyword found
    else
      [keyword_service, rest.join(' '), account_id]
    end
  end

  class NoAccount < Exception; end

  # this is pretty much just to make tests easier to read
  class ParsedSms < Array
    def prefix;     self[0] end
    def keyword;    self[1] end
    def message;    self[2] end
    def account_id; self[3] end
  end

end
