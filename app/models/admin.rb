class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(auth)
    return unless auth.info.email == ENV['ADMIN_EMAIL'] # Only allow me to be an admin

    where(provider: auth.provider, uid: auth.uid).first_or_create do |admin|
      admin.email = auth.info.email
      admin.encrypted_password = Devise.friendly_token[0, 20]
      admin.access_token = auth.credentials.token
      admin.expires_at = auth.credentials.expires_at
      admin.refresh_token = auth.credentials.refresh_token
      admin.scope = auth.credentials.scope
    end
  end
end
