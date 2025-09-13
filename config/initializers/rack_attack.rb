# frozen_string_literal: true

if defined?(Rack::Attack)
  class Rack::Attack
  # Throttle POST lead submissions by IP: 10 req/min, 200/hour
  throttle("leads/ip/minute", limit: 10, period: 1.minute) do |req|
    req.ip if req.post? && req.path =~ %r{^/api/landing_pages/[^/]+/leads$}
  end

  throttle("leads/ip/hour", limit: 200, period: 1.hour) do |req|
    req.ip if req.post? && req.path =~ %r{^/api/landing_pages/[^/]+/leads$}
  end

  # Throttle per landing page: 60 req/min aggregate
  throttle("leads/landing_page/minute", limit: 60, period: 1.minute) do |req|
    if req.post? && req.path =~ %r{^/api/landing_pages/([^/]+)/leads$}
      Rack::Attack::StoreProxy::RedisStoreProxy.normalize_key("lp:#{Regexp.last_match(1)}") rescue Regexp.last_match(1)
    end
  end

  # Track failed CAPTCHA attempts per IP to inform temp bans externally/logs
  blocklist("ban/ip/failed_captcha") do |req|
    key = "captcha:failures:#{req.ip}"
    failures = Rails.cache.read(key).to_i
    failures >= 5
  end

    self.throttled_responder = lambda do |request|
      [ 429,
        { "Content-Type" => "application/json" },
        [ { error: "rate_limited" }.to_json ] ]
    end
  end
end
