class BookingsController < ApplicationController
  def index
    @bookings = current_user.bookings.by_status(params[:status]).by_create_date
  end

  def new
    render partial: 'new', layout: 'modal', locals: {
      booking: Booking.new,
      parking: Parking.find(params[:parking_id])
    }
  end

  def create
    booking = Booking.new(booking_params)
    booking.user = current_user
    booking.status = :active

    if booking.save
      # ReleaseBookingJob.set(wait_until: booking.end_date).perform_later(booking)
      redirect_to bookings_url
    else
      render json: { errors: booking.errors }, status: :unprocessable_entity
    end
  end

  def confirm_destroy
    booking = Booking.find(params[:id])
    render partial: 'confirm_destroy', layout: 'modal', locals: { id: booking.id }
  end

  def destroy
    booking = Booking.find(params[:id])
    if booking.delete
      booking.spot.release
      redirect_to bookings_url
    end
  end

  def confirm_release
    booking = Booking.find(params[:id])
    render partial: 'confirm_release', layout: 'modal', locals: { id: booking.id }
  end

  def release
    booking = Booking.find(params[:id])
    booking.archive
    redirect_to bookings_url
  end

  private

  def booking_params
    params.fetch(:booking, {}).permit(:spot_id, :start_date, :car_name, :car_plates, :timezone)
  end
end
