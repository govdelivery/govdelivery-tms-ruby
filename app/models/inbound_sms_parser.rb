module InboundSmsParser
  module_function

  def parse(sms_body, vendor)
    san_string = Keyword.sanitize_string(sms_body)
    account_id = find_account_id(san_string.split.first, vendor)
    prefix, rest = extract_prefix(san_string, vendor)
    keyword_service, message = extract_keyword(rest, vendor, account_id)
    ParsedSms.new [prefix, keyword_service, message, account_id]
  end

  # if we can idenfity an account by prefix, use that
  # otherwise
  def find_account_id(first_word, vendor)
    account_id = vendor.sms_prefixes.account_id_for_prefix(first_word) if vendor.sms_prefixes.any? && first_word.present?
    account_id = vendor.accounts.first.id if account_id.blank? && vendor.accounts.count == 1
    account_id
  end

  # returns [nil, full string] or [prefix, partial string, account_id]
  # the prefix determines the account
  def extract_prefix(s, vendor)
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
      [keyword_service, s, account_id] # return the full string, no keyword found
    else
      [keyword_service, rest.join(' '), account_id]
    end
  end

  class NoAccount < Exception; end

  # this is pretty much just to make tests easier to read
  class ParsedSms < Array
    def prefix
      self[0]
    end

    def keyword_service
      self[1]
    end

    def message
      self[2]
    end

    def account_id
      self[3]
    end
  end
end
