collection @actions
attributes :name, :action_type

node('_links') { |m| {:self => keyword_action_path(@keyword, m)} }