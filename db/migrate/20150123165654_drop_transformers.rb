class DropTransformers < ActiveRecord::Migration
  def change
    drop_table :transformers
  end
end
