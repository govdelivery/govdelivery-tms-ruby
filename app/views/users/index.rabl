object @account
attributes :users
node(:_links) do |a|
  {:self => account_users_path(a),
   :account => account_path(a)}
end