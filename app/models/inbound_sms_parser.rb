module InboundSmsParser

  module_function

  def parse sms_body, vendor
    san_string = sanitize_string(sms_body)
    account_id = find_account_id(san_string.split.first,vendor)
    prefix, rest = extract_prefix(san_string, vendor)
    keyword, message = extract_keyword(rest, vendor, account_id)
    ParsedSms.new [prefix, keyword, message, account_id]
  end


  def sanitize_string s
    Keyword.sanitize_string(s)
  end

  def find_account_id first_word, vendor
    if vendor.shared?
      vendor.sms_prefixes.account_id_for_prefix(first_word)
    elsif (account_id = vendor.accounts.first.try(:id)).present?
      #wow this feels dangerous, private vendors are not enforced
      # TODO: validate private vendor has one or zero accounts in vendor
      account_id
    else
      nil #this might resolve to a help, stop or default on the vendor
    end
  end

  # returns [nil, full string] or [prefix, partial string, account_id]
  # the prefix determines the account
  def extract_prefix s, vendor
    first_word, *rest = s.split
    if vendor.sms_prefixes.account_id_for_prefix(first_word) # do it again I guess(?)
      [first_word, rest.join(' ')]
    else
      [nil, s]
    end
  end

  # returns [nil, message, nil] or [keyword, message, account_id]
  def extract_keyword(s, vendor, account_id)
    first_word, *rest = s.split
    keyword = Keyword.get_keyword(first_word, vendor, account_id)
    if keyword.default?
      [keyword, s, account_id] #return the full string, no keyword found
    else
      [keyword, rest.join(' '), account_id]
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
