class ExpiredRecipientQuery
  def self.new(recipient_scope)
    vendor_scope = recipient_scope.reflections[:vendor].klass
    vendors = vendor_scope.arel_table
    timeout = vendors[:delivery_timeout] / 24.hours
    sysdate = Arel.sql('sysdate')

    vendors_with_timeout_value = vendor_scope.
      where(vendors[:delivery_timeout].not_eq(nil))
    old_enough = Arel::Nodes::LessThan.new(
      recipient_scope.arel_table[:sent_at] + timeout,
      sysdate
    )

    recipient_scope.
      sending.
      joins(:vendor).
      merge(vendors_with_timeout_value).
      where(old_enough)
  end
end
