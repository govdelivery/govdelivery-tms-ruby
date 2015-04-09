class RenameFallThroughAccountLevelKeywords < ActiveRecord::Migration
  def change
    Keyword.where(name: 'Keywords::AccountStop').update_all(name: 'stop')
    Keyword.where(name: 'Keywords::AccountHelp').update_all(name: 'help')
    Keyword.where(name: 'Keywords::AccountDefault').update_all(name: 'default')
  end
end
