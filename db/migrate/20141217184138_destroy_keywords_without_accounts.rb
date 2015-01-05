class DestroyKeywordsWithoutAccounts < ActiveRecord::Migration
  def change
    keywords = Keyword.where('account_id IS NULL')
    puts "#{keywords.count} keywords without accounts found!"
    keywords.each do |keyword|
      puts "destroying #{keyword.inspect}"
      keyword.destroy
    end
    change_column :keywords, :account_id, :integer, null: false
  end
end
