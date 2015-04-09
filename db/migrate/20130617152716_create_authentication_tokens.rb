class CreateAuthenticationTokens < ActiveRecord::Migration
  def change
    create_table :authentication_tokens, force: true do |t|
      t.references :user, null: false
      t.string :token, null: false
      t.timestamps
    end

    add_index :authentication_tokens, :token, unique: true

    User.all.each do |u|
      u.ensure_authentication_token
      u.save!
    end
  end
end
