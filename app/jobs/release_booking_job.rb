class ReleaseBookingJob < ApplicationJob
  queue_as :default

  def perform(booking)
    # Do something later
    booking.update(status: :archive) && booking.spot.release if booking.present?
  end
end
