# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper

  def authenticate_user!
    return if user_signed_in?

    redirect_to root_path, alert: 'You need to sign in before continuing.'
  end
end
