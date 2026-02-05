class CreateCalls < ActiveRecord::Migration[8.1]
  def change
    create_table :calls do |t|
      t.references :content, null: false, foreign_key: true
      t.references :influencer, null: false, foreign_key: true
      t.references :asset, null: false, foreign_key: true
      t.string :direction, null: false
      t.decimal :confidence, null: false, precision: 5, scale: 4
      t.text :quote
      t.text :reasoning
      t.datetime :called_at, null: false

      t.timestamps
    end

    add_index :calls, [:influencer_id, :called_at]
    add_index :calls, [:asset_id, :called_at]
    add_index :calls, :direction
  end
end
