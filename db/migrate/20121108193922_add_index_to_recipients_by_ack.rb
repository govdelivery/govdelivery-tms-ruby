class AddIndexToRecipientsByAck < ActiveRecord::Migration
  def change
    add_index(:recipients, :ack)
  end
end
