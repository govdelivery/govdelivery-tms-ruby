object @account
attributes :users

node(:_links) do |a|
  {:self => account_users_path(a.id),
   :account => account_path(a.id)}
end