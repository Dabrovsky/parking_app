class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, #:rememberable,
         :omniauthable, omniauth_providers: [:slack]

  has_many :services, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :spots, through: :bookings

  validates_presence_of :current_password, message: 'we need to confirm your changes', on: :update

  before_destroy :release_spots

  def release_spots
    spots = self.spots
    spots.map { |spot| spot.update({status: 0}) }
  end

  def self.from_omniauth(auth)
    service = ::Service.includes(:user).find_by(provider: auth[:provider], uid: auth[:uid])

    unless service.present?
      OpenStruct.new({user: nil})
    else
      service
    end
  end
end
