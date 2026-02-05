class AddExtractionStatusToContents < ActiveRecord::Migration[8.1]
  def change
    add_column :contents, :calls_extracted_at, :datetime
    add_column :contents, :extraction_status, :string, default: "pending"
    add_index :contents, :extraction_status
    add_index :contents, :calls_extracted_at
  end
end
