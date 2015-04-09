class ChangeKeywordResponseText < ActiveRecord::Migration
  def change
    Keyword.where(response_text: 'Go to http://bit.ly/govdhelp for help').update_all(response_text: 'This service is provided by GovDelivery. If you are a customer in need of assistance, please contact customer support.')
  end
end
