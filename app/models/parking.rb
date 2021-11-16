class Parking < ApplicationRecord
  belongs_to :company
  has_many :spots
end
