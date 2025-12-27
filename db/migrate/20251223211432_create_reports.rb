class CreateReports < ActiveRecord::Migration[8.0]
  def change
    create_table :reports do |t|
      t.references :user, null: false, foreign_key: true
      t.references :neighborhood, null: false, foreign_key: true
      t.string :report_type, null: false
      t.string :value, null: false
      t.text :details
      t.decimal :confidence, precision: 3, scale: 2, default: 0.5
      t.integer :agreements_count, default: 0
      t.integer :disagreements_count, default: 0
      t.datetime :verified_at

      t.timestamps
    end

    add_index :reports, [:report_type, :neighborhood_id]
    add_index :reports, :verified_at
    add_index :reports, [:user_id, :neighborhood_id, :report_type], unique: true, 
              name: 'index_reports_on_user_neighborhood_type_unique'
  end
end
