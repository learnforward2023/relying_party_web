# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  include HttpRequestable

  before_action :verify_state, only: :callback

  def callback
    token_response = fetch_token(params[:code])
    validate_id_token(token_response['id_token'])

    user = find_or_create_user
    create_user_session(user)

    redirect_to root_path, notice: 'Signed in successfully'
  rescue StandardError => e
    redirect_to root_path, alert: "Authentication failed: #{e.message}"
  end

  def failure
    redirect_to root_path, alert: 'Authentication failed'
  end

  private

  def verify_state
    redirect_to root_path, alert: 'State mismatch error' if params[:state] != session[:state]
  end

  def fetch_token(code)
    post_request(ENV['IDP_TOKEN_ENDPOINT'], {
                   grant_type: ENV['STUDY_TOGETHER_GRANT_TYPE'],
                   code:,
                   redirect_uri: ENV['STUDY_TOGETHER_REDIRECT_URI'],
                   client_id: ENV['STUDY_TOGETHER_CLIENT_ID'],
                   client_secret: ENV['STUDY_TOGETHER_CLIENT_SECRET']
                 })
  end

  def validate_id_token(id_token)
    discovery_response = get_request(ENV['IDP_DISCOVERY_ENDPOINT'])
    jwks_uri = discovery_response['jwks_uri']
    keys = get_request(jwks_uri)['keys']

    decoded_token = JWT.decode(id_token, nil, true, {
                                 algorithm: 'RS256',
                                 jwks: { keys: },
                                 verify_aud: true,
                                 aud: ENV['STUDY_TOGETHER_CLIENT_ID']
                               })

    @payload = decoded_token.first
    validate_token_timestamps
  end

  def validate_token_timestamps
    raise 'ID token has expired' if Time.zone.at(@payload['exp']) < Time.zone.now
    raise 'ID token is not valid yet' if Time.zone.at(@payload['iat']) > Time.zone.now
  end

  def find_or_create_user
    User.find_or_create_by(uuid: @payload['sub']) do |user|
      user.email = @payload['email']
    end
  end

  def create_user_session(user)
    UserSession.create(user:, session_id: request.session_options[:id].private_id)
    session[:uuid] = user.uuid
  end
end
