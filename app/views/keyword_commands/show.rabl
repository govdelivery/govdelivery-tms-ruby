object @command
attributes :name, :command_type, :params, :created_at, :updated_at
if root_object
  if root_object.errors.empty?
    node(:_links) do |a|
      hsh = {:self => keyword_command_path(@keyword, a),
             :keyword => keyword_path(@keyword)}
      hsh[:command_actions] = keyword_command_actions_path(@keyword, a) if a.command_actions.any?
      hsh
    end
  else
    node(:_links) { |a| {:self => keyword_commands_path(@keyword),
                         :keyword => keyword_path(@keyword)}
    }
    node(:errors) { |command| command.errors }
  end

end