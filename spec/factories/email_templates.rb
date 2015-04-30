FactoryGirl.define do
  factory :email_template do
    body '<html><body>[TEMPLATE]</body></html>'
    subject 'template subject'
    link_tracking_parameters 'tracking=param&one=two'
    macros { {'[TEMPLATE]' => 'YES'} }
    click_tracking_enabled true
    open_tracking_enabled false
    user
    account
    from_address
  end
end
