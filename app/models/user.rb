# frozen_string_literal: true

class User < ApplicationRecord
  has_many :user_sessions, dependent: :destroy

  validates :uuid, presence: true, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP } # rubocop:disable Rails/UniqueValidationWithoutIndex

  def invalidate_session!
    user_sessions.each do |user_session|
      ActiveRecord::SessionStore::Session.where(session_id: user_session.session_id).delete_all
      user_session.destroy!
    end
  end
end
