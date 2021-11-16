require 'openssl'
require 'active_support/security_utils'

class Slack::CommandsController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!
  before_action :verify_request

  def initialize
    @actions = %w( book release list my )
  end

  def create
    empty_params = params[:text].blank?
    if empty_params
      resp = invalid_query
    else
      @queries = params[:text].split()

      unless @actions.include? @queries.first || @queries.size === 5
        resp = invalid_query
      else
        resp = send(@queries.first)
      end
    end

    render json: resp
  end

  def book
    if @queries.size < 5
      parkings = Parking.all.map { |parking| "• #{parking.company.name}, id: #{parking.id} \n" }

      {
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Hi #{params[:user_name]} :wave:"
            }
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "To booking your request you need to pass params in your query. \n Please type `/parking book parking_id car_name car_plates date [year-month-day]` for ex. `/parking book 1 Audi KR1234_ 2021-11-15`."
            }
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Bellow is a list of available parkings:"
            }
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": parkings.join('').to_s
            }
          }
        ]
      }
    else
      parking = Parking.find(@queries[1].to_i)
      booking = Booking.create!(
        spot_id: parking.spots.availables.first.id,
        user_id: Service.includes(:user).find_by(uid: params[:user_id]).user.id,
        status: :active,
        car_name: @queries[2],
        car_plates: @queries[3],
        start_date: Date.parse(@queries[4])
      )

      {
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Success!"
            }
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "We saved yor booking for #{booking.car_details}. Your booking id is: #{booking.id}. \n You can release this booking by execute command `/parking release #{booking.id}`."
            }
          }
        ]
      }
    end
  end

  def list
    parkings = Parking.all.map { |parking| "• #{parking.company.name} _(#{parking.address})_, id: #{parking.id} \n" }

    {
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Hi #{params[:user_name]} :wave:"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Here is a list of available parkings:"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": parkings.join('').to_s
          }
        }
      ]
    }
  end

  def release
    booking = Booking.find(@queries[1].to_i)
    if booking.present?
      booking.archive

      {
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Thank you,"
            }
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Your booking has been release."
            }
          }
        ]
      }
    end
  end

  def my
    user = Service.includes(:user).find_by(uid: params[:user_id]).user
    bookings = Booking.by_create_date.where(user: user).map { |booking| "• [#{booking.id}] #{booking.spot.parking.address} _(status: #{booking.status})_ \n" }

    {
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Hi,"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Here is a list of your bookings:"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": bookings.join('').to_s
          }
        }
      ]
    }
  end

  private

  def verify_request
    timestamp = request.headers['X-Slack-Request-Timestamp']
    if (Time.now.to_i - timestamp.to_i).abs > 60 * 5
      head :unauthorized
    end

    sig_basestring  = "v0:#{timestamp}:#{request.raw_post}"
    my_signature    = "v0=" + OpenSSL::HMAC.hexdigest('SHA256', 'e8cd16d851934ac45027593dc3f4e9d6', sig_basestring)
    slack_signature = request.headers['X-Slack-Signature']

    unless ActiveSupport::SecurityUtils.secure_compare(my_signature, slack_signature)
      head :unauthorized
    end
  end

  def invalid_query
    {
      "blocks": [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "Sorry, invalid command. \n Available commands is:"
          }
        },
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "• `/parking book *args` (create new booking) \n • `/parking release [id]` (release booked spot) \n • `/parking list` (list of available parkings) \n • `/parking my` (list of your bookings)"
          }
        }
      ]
    }
  end
end
