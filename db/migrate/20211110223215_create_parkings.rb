class CreateParkings < ActiveRecord::Migration[6.1]
  def change
    create_table :parkings do |t|
      t.references :company, null: false, foreign_key: true
      t.string :address

      t.timestamps
    end
  end
end
