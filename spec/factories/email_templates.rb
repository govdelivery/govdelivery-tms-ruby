FactoryGirl.define do
  factory :email_template do
    body '<html><body>[HELLO]</body></html>'
    subject 'This is a test'
    link_tracking_parameters 'tracking=param&one=two'
    macros {{'[HELLO]' => 'WORLD'}}
    click_tracking_enabled false
    open_tracking_enabled false
    user
    account
    from_address
  end
end
