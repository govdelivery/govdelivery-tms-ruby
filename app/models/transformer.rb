class Transformer < ActiveRecord::Base

  attr_accessible :content_type, :transformer_class

  validates_presence_of :transformer_class
  validates_presence_of :content_type
  validates_presence_of :account

  validates_uniqueness_of :content_type, scope: :account_id

  belongs_to :account

  def transform(payload, type)
    get_transformer(payload, type).transform
  end

private
  def get_transformer(payload, type)
    Transformers.const_get(transformer_class.camelize).new payload, type
  end
end
