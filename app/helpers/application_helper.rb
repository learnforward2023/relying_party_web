# frozen_string_literal: true

module ApplicationHelper
  def current_user
    @current_user ||= User.find_by(uuid: session[:uuid])
  end

  def user_signed_in?
    current_user.present?
  end
end
