class Booking < ApplicationRecord
    after_commit :set_end_date, :book_spot, on: :create

    belongs_to :spot
    belongs_to :user

    attr_accessor :timezone

    validates :start_date, :car_name, :car_plates, presence: true

    enum status: {
        archive: 0,
        active: 1
    }

    scope :by_create_date, ->{ order(created_at: :desc) }
    scope :by_status, lambda { |status|
        where(status: status) if status.present?
    }

    def archive
        update({status: :archive})
        spot.release
    end

    def car_details
        "#{car_name}, #{car_plates}"
    end

    private

    def set_end_date
        update(end_date: start_date.to_date.in_time_zone(timezone).end_of_day)
    end

    def book_spot
        spot.book
    end
end
