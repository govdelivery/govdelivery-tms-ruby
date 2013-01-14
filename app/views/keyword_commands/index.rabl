collection @commands
attributes :name, :command_type

node('_links') { |m| {:self => keyword_command_path(@keyword, m)} }