object @command
attributes :name, :command_type, :params, :created_at, :updated_at
if @command
  unless @command.errors.empty?
    node(:errors) { |command| command.errors }
  end
  node(:_links) do |a|
    {:self => a.persisted? ? keyword_command_path(@keyword, a) : keyword_commands_path(@keyword)}
  end
end