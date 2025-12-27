class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :phone_number, null: false
      t.string :sms_verification_code
      t.datetime :sms_verified_at
      t.decimal :trust_score, precision: 3, scale: 2, default: 0.5
      t.integer :reports_count, default: 0
      t.integer :verifications_count, default: 0
      t.decimal :consistency_score, precision: 3, scale: 2, default: 0.5

      t.timestamps
    end

    add_index :users, :phone_number, unique: true
  end
end