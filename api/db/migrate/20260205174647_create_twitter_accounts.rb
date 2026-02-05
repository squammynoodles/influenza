class CreateTwitterAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :twitter_accounts do |t|
      t.references :influencer, null: false, foreign_key: true
      t.string :username, null: false
      t.string :display_name
      t.string :profile_image_url
      t.text :bio
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :twitter_accounts, :username, unique: true
  end
end
