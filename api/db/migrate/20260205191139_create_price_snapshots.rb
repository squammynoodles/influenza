class CreatePriceSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :price_snapshots do |t|
      t.references :asset, null: false, foreign_key: true
      t.datetime :timestamp, null: false
      t.decimal :open, precision: 20, scale: 8
      t.decimal :high, precision: 20, scale: 8
      t.decimal :low, precision: 20, scale: 8
      t.decimal :close, precision: 20, scale: 8, null: false
      t.bigint :volume

      t.timestamps
    end

    add_index :price_snapshots, [:asset_id, :timestamp], unique: true
    add_index :price_snapshots, :timestamp
  end
end
