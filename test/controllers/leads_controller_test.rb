require "test_helper"

class LeadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lead = leads(:one)
  end

  test "should get index" do
    get leads_url
    assert_response :success
  end

  test "should get new" do
    get new_lead_url
    assert_response :success
  end

  test "should create lead" do
    assert_difference("Lead.count") do
      post leads_url, params: { lead: { campaign_id: @lead.campaign_id, consent_source: @lead.consent_source, consented_at: @lead.consented_at, data: @lead.data, email_bidx: @lead.email_bidx, email_ciphertext: @lead.email_ciphertext, fbclid: @lead.fbclid, gclid: @lead.gclid, idempotency_key: @lead.idempotency_key, ip_address: @lead.ip_address, landing_page_id: @lead.landing_page_id, landing_url: @lead.landing_url, marketing_consent: @lead.marketing_consent, msclkid: @lead.msclkid, name: @lead.name, phone_bidx: @lead.phone_bidx, phone_ciphertext: @lead.phone_ciphertext, privacy_policy_version: @lead.privacy_policy_version, public_id: "L-#{SecureRandom.hex(3)}", referral_code: "RC-#{SecureRandom.hex(3)}", referrer_url: @lead.referrer_url, schema_version_at_submit: @lead.schema_version_at_submit, user_agent: @lead.user_agent, utm_campaign: @lead.utm_campaign, utm_content: @lead.utm_content, utm_medium: @lead.utm_medium, utm_source: @lead.utm_source, utm_term: @lead.utm_term } }
    end

    assert_redirected_to lead_url(Lead.last)
  end

  test "should show lead" do
    get lead_url(@lead)
    assert_response :success
  end

  test "should get edit" do
    get edit_lead_url(@lead)
    assert_response :success
  end

  test "should update lead" do
    patch lead_url(@lead), params: { lead: { campaign_id: @lead.campaign_id, consent_source: @lead.consent_source, consented_at: @lead.consented_at, data: @lead.data, email_bidx: @lead.email_bidx, email_ciphertext: @lead.email_ciphertext, fbclid: @lead.fbclid, gclid: @lead.gclid, idempotency_key: @lead.idempotency_key, ip_address: @lead.ip_address, landing_page_id: @lead.landing_page_id, landing_url: @lead.landing_url, marketing_consent: @lead.marketing_consent, msclkid: @lead.msclkid, name: @lead.name, phone_bidx: @lead.phone_bidx, phone_ciphertext: @lead.phone_ciphertext, privacy_policy_version: @lead.privacy_policy_version, public_id: @lead.public_id, referral_code: @lead.referral_code, referrer_url: @lead.referrer_url, schema_version_at_submit: @lead.schema_version_at_submit, user_agent: @lead.user_agent, utm_campaign: @lead.utm_campaign, utm_content: @lead.utm_content, utm_medium: @lead.utm_medium, utm_source: @lead.utm_source, utm_term: @lead.utm_term } }
    assert_redirected_to lead_url(@lead)
  end

  test "should destroy lead" do
    assert_difference("Lead.count", -1) do
      delete lead_url(@lead)
    end

    assert_redirected_to leads_url
  end
end
