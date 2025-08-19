class LeadMailer < ApplicationMailer
  helper_method :coupon_code, :referral_link

  # Notify internal team/admin a lead was created
  def admin_new_lead(lead)
    @lead = lead
    @referred_by = Lead.find_by(id: lead.referred_by_lead_id)
    mail(
      to: admin_email,
      subject: "New lead: #{lead.name} (#{lead.public_id})"
    )
  end

  # Confirm to the lead their submission and share coupon/referral link
  def lead_confirmation(lead)
    @lead = lead
    @referred_by = Lead.find_by(id: lead.referred_by_lead_id)
    mail(
      to: lead.email,
      subject: "You're on the waitlist! Your coupon code inside"
    )
  end

  private

  def admin_email
    ENV["ADMIN_EMAIL"].presence || (Rails.application.credentials.dig(:admin_email) rescue nil) || "admin@example.com"
  end

  def coupon_code
    ENV["COUPON_CODE"].presence || (Rails.application.credentials.dig(:coupon_code) rescue nil) || "EARLY50"
  end

  def referral_link
    base_url = @lead.landing_url.presence
    return nil if base_url.blank? || @lead.referral_code.blank?

    begin
      uri = URI.parse(base_url)
      params = Rack::Utils.parse_nested_query(uri.query)
      params["ref"] = @lead.referral_code
      uri.query = params.to_query
      uri.to_s
    rescue StandardError
      # Fallback to naive concatenation
      separator = base_url.include?("?") ? "&" : "?"
      base_url + "#{separator}ref=#{@lead.referral_code}"
    end
  end
end
