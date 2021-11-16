class CreateBookings < ActiveRecord::Migration[6.1]
  def change
    create_table :bookings do |t|
      t.references :spot, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status
      t.string :car_name
      t.string :car_plates
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
