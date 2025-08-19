class ApplicationMailer < ActionMailer::Base
  default from: -> { default_from_address }
  layout "mailer"

  private

  def default_from_address
    ENV["DEFAULT_FROM_EMAIL"].presence || (Rails.application.credentials.dig(:mail, :from) rescue nil) || "no-reply@example.com"
  end
end
