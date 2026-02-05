class CreateContents < ActiveRecord::Migration[8.1]
  def change
    create_table :contents do |t|
      t.references :influencer, null: false, foreign_key: true
      t.string :type, null: false
      t.string :external_id, null: false
      t.string :title
      t.text :body
      t.text :transcript
      t.datetime :published_at
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :contents, [:external_id, :type], unique: true
    add_index :contents, [:influencer_id, :published_at]
    add_index :contents, :type
  end
end
