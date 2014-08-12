class CreateTransformers < ActiveRecord::Migration
  def change
    create_table :transformers do |t|
      t.references :account
      t.string :transformer_class
      t.string :content_type
      t.timestamps
    end
  end
end
