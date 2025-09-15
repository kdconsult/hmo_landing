class Api::LeadsController < ApplicationController
  protect_from_forgery with: :null_session

  # POST /api/landing_pages/:slug/leads
  def create
    landing_page = LandingPage.published.find_by!(slug: params[:slug])

    # Idempotency by header (retain for 24h) – naive in-memory for now via table
    idempotency_key = request.headers["Idempotency-Key"].presence
    if idempotency_key.present?
      endpoint = "POST:/api/landing_pages/#{landing_page.slug}/leads"
      request_hash = Digest::SHA256.hexdigest(request.raw_post.to_s)
      if (ikey = ApiIdempotencyKey.valid.find_by(key: idempotency_key, endpoint: endpoint, request_hash: request_hash))
        return render json: ikey.response_body, status: ikey.response_status
      end
    end

    payload = params.permit(:recaptcha_token, :ref, core: [ :name, :email, :phone, :marketing_consent ], custom: {}, utm: [ :utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content ])

    # Verify reCAPTCHA v3 (expects ENV variables set)
    unless verify_recaptcha_v3(payload[:recaptcha_token])
      increment_failed_captcha!(request)
      render json: { error: "invalid_recaptcha" }, status: :forbidden and return
    end

    core = payload[:core] || {}
    custom = payload[:custom] || {}
    utm = payload[:utm] || {}

    if ActiveModel::Type::Boolean.new.cast(core[:marketing_consent]) != true
      render json: { errors: { marketing_consent: [ "must be accepted" ] } }, status: :unprocessable_content and return
    end

    lead = Lead.new(
      campaign: landing_page.campaign,
      landing_page: landing_page,
      public_id: SecureRandom.uuid,
      name: core[:name],
      email_ciphertext: core[:email],
      phone_ciphertext: core[:phone],
      marketing_consent: true,
      consented_at: Time.current,
      consent_source: request.referrer || request.original_url,
      privacy_policy_version: "v1",
      data: custom.presence || {},
      utm_source: utm[:utm_source],
      utm_medium: utm[:utm_medium],
      utm_campaign: utm[:utm_campaign],
      utm_term: utm[:utm_term],
      utm_content: utm[:utm_content],
      gclid: params[:gclid],
      fbclid: params[:fbclid],
      msclkid: params[:msclkid],
      referrer_url: request.referer,
      landing_url: request.original_url,
      user_agent: request.user_agent,
      ip_address: request.remote_ip,
      referral_code: generate_referral_code(landing_page.campaign),
      idempotency_key: idempotency_key,
      schema_version_at_submit: landing_page.schema_version
    )

    if (ref = payload[:ref]).present?
      referred_by = Lead.find_by(campaign_id: landing_page.campaign_id, referral_code: ref)
      lead.referred_by_lead_id = referred_by&.id
    end

    if lead.save
      body = { id: lead.public_id, status: "accepted", referral_code: lead.referral_code }
      persist_idempotency(idempotency_key, landing_page, body, 201)
      render json: body, status: :created
    else
      body = { errors: lead.errors }
      persist_idempotency(idempotency_key, landing_page, body, 422)
      render json: body, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "not_found" }, status: :not_found
  end

  # GET /api/landing_pages/:slug/leads
  def index
    landing_page = LandingPage.published.find_by!(slug: params[:slug])
    leads = landing_page.leads.order(created_at: :desc).select(:id, :created_at)
    render json: leads
  rescue ActiveRecord::RecordNotFound
    render json: { error: "not_found" }, status: :not_found
  end

  private

  def verify_recaptcha_v3(token)
    secret = ENV["RECAPTCHA_V3_SECRET_KEY"].to_s
    return true if secret.blank? # allow in dev/test without secret
    return false if token.blank?

    response = Net::HTTP.post_form(URI("https://www.google.com/recaptcha/api/siteverify"), { "secret" => secret, "response" => token })
    body = JSON.parse(response.body) rescue {}
    body["success"] == true && body["score"].to_f >= 0.5
  rescue StandardError
    false
  end

  def generate_referral_code(campaign)
    loop do
      code = "R" + SecureRandom.hex(4)
      break code unless Lead.exists?(campaign_id: campaign.id, referral_code: code)
    end
  end

  def persist_idempotency(idempotency_key, landing_page, body, status)
    return if idempotency_key.blank?
    endpoint = "POST:/api/landing_pages/#{landing_page.slug}/leads"
    request_hash = Digest::SHA256.hexdigest(request.raw_post.to_s)
    ApiIdempotencyKey.create!(
      key: idempotency_key,
      endpoint: endpoint,
      request_hash: request_hash,
      response_body: body,
      response_status: status,
      expires_at: 24.hours.from_now
    )
  rescue ActiveRecord::RecordNotUnique
    # Ignore race conditions
  end

  def increment_failed_captcha!(request)
    return unless defined?(Rack::Attack)
    key = "captcha:failures:#{request.ip}"
    count = (Rails.cache.read(key) || 0).to_i + 1
    Rails.cache.write(key, count, expires_in: 5.minutes)
  end
end
