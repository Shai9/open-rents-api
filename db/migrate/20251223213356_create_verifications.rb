class CreateVerifications < ActiveRecord::Migration[8.0]
  def change
    create_table :verifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :report, null: false, foreign_key: true
      t.boolean :agrees, null: false
      t.text :comment
      t.decimal :weight, precision: 3, scale: 2, default: 1.0

      t.timestamps
    end

    add_index :verifications, [:user_id, :report_id], unique: true
    
    add_index :verifications, [:report_id, :agrees]
  end
end
