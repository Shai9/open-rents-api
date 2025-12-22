class CreateNeighborhoods < ActiveRecord::Migration[7.1]
  def change
    create_table :neighborhoods do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :county
      t.string :ward
      t.jsonb :metadata

      t.timestamps
    end

    add_index :neighborhoods, :slug, unique: true
    add_index :neighborhoods, :name, unique: true
  end
end