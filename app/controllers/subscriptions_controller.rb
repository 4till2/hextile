class SubscriptionsController < ApplicationController

  def subscribe
    email = params[:email]
    subscribed = Subscription.subscribe(email)
    message = subscribed ? 'You have subscribed!' : 'Oops is that email valid?'
    render turbo_stream: turbo_stream.replace('subscription_container',
                                              partial: 'subscriptions/subscribe',
                                              locals: { response: true, message: message })
  end

  def unsubscribe
    email = params[:email]
    token = params[:token]

    success = email && token && Subscription.unsubscribe(email, token)
    render 'subscriptions/unsubscribed', locals: { success: success }
  end

  def confirm
    email = params[:email]
    token = params[:token]
    success = email && token && Subscription.validate_email(email, token)
    render 'subscriptions/confirmed', locals: { success: success }
  end
end