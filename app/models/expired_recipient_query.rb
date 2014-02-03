class ExpiredRecipientQuery
  def self.new(recipient_scope)
    sending_recipients = recipient_scope.sending

    vendors = recipient_scope.reflections[:vendor].klass.arel_table
    timeout = vendors[:delivery_timeout] / 24.hours
    sysdate = Arel.sql('sysdate')

    old_enough = Arel::Nodes::LessThan.new(
      recipient_scope.arel_table[:sent_at] + timeout,
      Arel.sql('sysdate')
    )

    # In Oracle, comparing null to anything (including null) returns zero rows.
    # Additionally, any operations on null return null (e.g. null + 1 = null).
    # This means we don't need to filter out vendors with null timeout or
    # recipients with null sent_at.
    sending_recipients.
      joins(:vendor).
      where(old_enough)
  end
end
