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

    @campaign = Campaign.active.find_by(slug: @slug)
    if @campaign.nil?
      redirect_to root_path and return
    end
    render :home
  end

  def welcome
    @campaigns = Campaign.current

    render :welcome
  end
end
