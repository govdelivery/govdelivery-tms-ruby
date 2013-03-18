object @command
attributes :name, :command_type, :params, :created_at, :updated_at
if @command
  if @command.errors.empty?
    node(:_links) do |a|
      {:self => keyword_command_path(@keyword, a),
       :command_actions => keyword_command_actions_path(@keyword, a)}
    end
  else
    node(:_links) { |a| {:self => keyword_commands_path(@keyword)} }
    node(:errors) { |command| command.errors }
  end

end