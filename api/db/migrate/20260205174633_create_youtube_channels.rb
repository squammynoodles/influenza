class CreateYoutubeChannels < ActiveRecord::Migration[8.1]
  def change
    create_table :youtube_channels do |t|
      t.references :influencer, null: false, foreign_key: true
      t.string :channel_id, null: false
      t.string :title
      t.text :description
      t.string :thumbnail_url
      t.string :uploads_playlist_id
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :youtube_channels, :channel_id, unique: true
  end
end
