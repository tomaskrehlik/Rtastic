class Feedback < ActiveRecord::Base
  attr_accessible :message
  belongs_to :user

  validate :user_id, presence: true
end
