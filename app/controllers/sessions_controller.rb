# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    redirect_to authorization_url
  end

  def destroy
    user_session = UserSession.find_by(session_id:)
    if user_session
      user_session.destroy
      ActiveRecord::SessionStore::Session.where(session_id:).delete_all
    end

    reset_session
    redirect_to root_path, notice: 'Signed out successfully'
  end

  private

  def authorization_url
    client_id = ENV['STUDY_TOGETHER_CLIENT_ID']
    redirect_uri = ENV['STUDY_TOGETHER_REDIRECT_URI']
    scope = ENV['STUDY_TOGETHER_SCOPE']
    state = SecureRandom.hex(16)
    session[:state] = state

    "#{ENV['IDP_AUTHORIZE_ENDPOINT']}?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}&state=#{state}"
  end

  def session_id
    @session_id ||= request.session_options[:id].private_id
  end
end
