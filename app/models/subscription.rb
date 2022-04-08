# I intend to implement automatic weekly emails summarizing the weeks activities. For now this is just to allow subscriptions
class Subscription < ApplicationRecord
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_uniqueness_of :email
  before_validation :create_token
  validates_presence_of :token

  def self.subscribe(email)
    subscription = Subscription.find_or_create_by!(email: email)
    token = subscription.token
    email = subscription.email
    # If desired send a confirmation email with callback to validate_email.
    # the callback should contain the emails address and token as parameters
    subscription
  end

  def self.unsubscribe(email, token)
    Subscription.destroy_by(email: email, token: token)
  end

  def self.validate_email(email, token)
    subscription = Subscription.find_by(email: email, token: token)
    subscription.confirmed = true && subscription.save! if subscription
  end

  private

  def create_token
    self.token = SecureRandom.hex(16) unless self.token.present?
  end

  def valid_token?(token)
    token.equal?(self.token)
  end
end
