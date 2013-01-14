object @action
attributes :name, :action_type, :params, :created_at, :updated_at
if @action
  unless @action.errors.empty?
    node(:errors) { |action| action.errors }
  end
  node(:_links) do |a|
    {:self => a.persisted? ? keyword_action_path(@keyword, a) : keyword_actions_path(@keyword)}
  end
end