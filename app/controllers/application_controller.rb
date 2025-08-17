class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Note: Rate limiting configured via Rack::Attack in production (see PRD). No-op here for dev/test.
end
