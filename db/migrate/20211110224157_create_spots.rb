class CreateSpots < ActiveRecord::Migration[6.1]
  def change
    create_table :spots do |t|
      t.references :parking, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
