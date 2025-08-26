class LeadsController < ApplicationController
  include Pagy::Backend
  before_action :set_lead, only: %i[ show edit update destroy ]

  # GET /leads or /leads.json
  def index
    @pagy, @leads = pagy(Lead.order(created_at: :desc), limit: 10)
  end

  # GET /leads/1 or /leads/1.json
  def show
  end

  # GET /leads/new
  def new
    @lead = Lead.new
  end

  # GET /leads/1/edit
  def edit
  end

  # POST /leads or /leads.json
  def create
    @lead = Lead.new(lead_params)

    respond_to do |format|
      if @lead.save
        format.html { redirect_to @lead, notice: "Lead was successfully created." }
        format.json { render :show, status: :created, location: @lead }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leads/1 or /leads/1.json
  def update
    respond_to do |format|
      if @lead.update(lead_params)
        format.html { redirect_to @lead, notice: "Lead was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @lead }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1 or /leads/1.json
  def destroy
    @lead.destroy!

    respond_to do |format|
      format.html { redirect_to leads_path, notice: "Lead was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lead
      @lead = Lead.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def lead_params
      params.require(:lead).permit(
        :campaign_id,
        :landing_page_id,
        :public_id,
        :name,
        # plaintext preferred
        :email,
        :phone,
        # legacy compatibility
        :email_ciphertext,
        :phone_ciphertext,
        :marketing_consent,
        :consented_at,
        :consent_source,
        :privacy_policy_version,
        :data,
        :utm_source,
        :utm_medium,
        :utm_campaign,
        :utm_term,
        :utm_content,
        :gclid,
        :fbclid,
        :msclkid,
        :referrer_url,
        :landing_url,
        :user_agent,
        :ip_address,
        :referral_code,
        :idempotency_key,
        :schema_version_at_submit
      )
    end
end
