class PagesController < ApplicationController
  def home
    @slug = params[:slug]
    @ref = params[:ref]
    # if @ref.present?
    #   @referrer = User.find_by(referral_code: @ref)
    # end
    # if @referrer.present?
    #   @referrer.referrals.create(user: current_user)
    # end

    @landing_page = LandingPage.published.find_by(slug: @slug)
    if @landing_page.nil?
      redirect_to root_path and return
    end
    if @landing_page&.status == "published" && @landing_page.template.present?
      # Render custom template from app/views/pages/<template>.html.erb
      render template: "pages/#{@landing_page.template}"
    else
      render :home
    end
  end

  def welcome
    @landing_pages = LandingPage.published.where(campaign: Campaign.active)

    render :welcome
  end
end
