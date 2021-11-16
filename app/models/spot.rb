class Spot < ApplicationRecord
    belongs_to :parking
    has_one :booking

    enum status: {
        available: 0,
        booked: 1
    }

    scope :availables, ->{ where(status: :available) }

    def available?
        status === :available.to_s
    end

    def book
        update({status: :booked})
    end

    def release
        update({status: :available})
    end
end
