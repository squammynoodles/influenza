class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.string :email, null: false
      t.references :invited_by, foreign_key: { to_table: :users }
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invitations, :email, unique: true
  end
end
