class CreateInfluencers < ActiveRecord::Migration[8.1]
  def change
    create_table :influencers do |t|
      t.string :name, null: false
      t.string :avatar_url
      t.text :bio

      t.timestamps
    end

    add_index :influencers, :name
  end
end
