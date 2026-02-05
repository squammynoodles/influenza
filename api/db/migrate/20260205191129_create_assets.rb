class CreateAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :assets do |t|
      t.string :symbol, null: false
      t.string :name, null: false
      t.string :asset_class, null: false
      t.string :coingecko_id
      t.string :yahoo_ticker
      t.jsonb :aliases, default: []

      t.timestamps
    end

    add_index :assets, :symbol, unique: true
    add_index :assets, :asset_class
  end
end
