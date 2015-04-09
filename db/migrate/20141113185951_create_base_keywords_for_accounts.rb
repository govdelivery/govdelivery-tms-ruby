class CreateBaseKeywordsForAccounts < ActiveRecord::Migration
  def change
    Account.all do |a|
      %w(stop start help default).each do |word|
        a.keywords.create(name: word) if a.keywords.where(name: word).empty?
      end
    end
  end
end
