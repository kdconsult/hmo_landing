class PagesController < ApplicationController
  def home
    @campaigns = Campaign.current

    render :home
  end
end
