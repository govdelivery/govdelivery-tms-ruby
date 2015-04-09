require 'test/unit'
require 'features/support/xact_support'

class TestLinkTester < Test::Unit::TestCase
  def test_prod_odm_links
    prod_link = 'https://odlinks.govdelivery.com/track?type=click&enid=bWFpbGluZ2lkPTk2c2Zrd2g4dm02aHBuazVndWcwZ3R1MWcmbWVzc2FnZWlkPVBSRC1PRE0tOTZzZmt3aDh2bTZocG5rNWd1ZzBndHUxZyZkYXRhYmFzZWlkPTEwMDEmc2VyaWFsPTIwNjMwNDkzOTgxNjI5MDM5NDQzNjU3NzE0OTU2OTI0MDkxMTE4OCZlbWFpbGlkPWNhbmFyaThkZEBnbWFpbC5jb20mdXNlcmlkPVNHUlJPcV9QYzVjUXRUeXphbFV1QVEmZmw9JmV4dHJhPU11bHRpdmFyaWF0ZUlkPSYmJg==&&&100&&&http://govdelivery.com'
    expected_link = 'http://govdelivery.com'
    expected_link_prefix = 'https://odlinks.govdelivery.com/track'
    link_tester = LinkTester.new
    assert(link_tester.test_link(prod_link, expected_link, expected_link_prefix))
  end
end
