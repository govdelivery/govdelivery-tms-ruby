collection @commands
attributes :name, :command_type, :params, :created_at, :updated_at

node('_links') { |m| {:self => keyword_command_path(@keyword, m)} }