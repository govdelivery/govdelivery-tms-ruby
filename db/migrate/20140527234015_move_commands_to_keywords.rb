class MoveCommandsToKeywords < ActiveRecord::Migration


  def up
    if defined?(EventHandler) and EventHandler.count > 0 #future proof

      # custom commands
      Command.all.each do |command|
        keyword = command.event_handler.keyword
        next unless keyword and puts " #{command.name}"
        puts "#{command.name} => #{keyword.name}"
        keyword.commands << command
      end

      # stop commands
      Account.all.each do |a|
        a.stop_keyword.commands << a.stop_handler.commands
      end
    end
  end

  def down
  end
end
