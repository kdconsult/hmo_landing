require "application_system_test_case"

class LeadsTest < ApplicationSystemTestCase
  setup do
    @lead = leads(:one)
  end

  test "visiting the index" do
    visit leads_url
    assert_selector "h1", text: "Leads"
  end

  test "should create lead" do
    visit leads_url
    click_on "New lead"

    select @lead.campaign.title, from: "Campaign"
    select @lead.landing_page.headline, from: "Landing page"
    fill_in "Public", with: @lead.public_id
    fill_in "Name", with: @lead.name
    fill_in "Email ciphertext", with: @lead.email_ciphertext
    fill_in "Phone ciphertext", with: @lead.phone_ciphertext
    check "Marketing consent" if @lead.marketing_consent
    fill_in "Consent source", with: @lead.consent_source
    fill_in "Privacy policy version", with: @lead.privacy_policy_version
    fill_in "Data", with: @lead.data.to_json
    fill_in "Utm source", with: @lead.utm_source
    fill_in "Utm medium", with: @lead.utm_medium
    fill_in "Utm campaign", with: @lead.utm_campaign
    fill_in "Utm term", with: @lead.utm_term
    fill_in "Utm content", with: @lead.utm_content
    fill_in "Gclid", with: @lead.gclid
    fill_in "Fbclid", with: @lead.fbclid
    fill_in "Msclkid", with: @lead.msclkid
    fill_in "Referrer url", with: @lead.referrer_url
    fill_in "Landing url", with: @lead.landing_url
    fill_in "User agent", with: @lead.user_agent
    fill_in "Ip address", with: @lead.ip_address
    fill_in "Referral code", with: @lead.referral_code
    fill_in "Idempotency key", with: @lead.idempotency_key
    fill_in "Schema version at submit", with: @lead.schema_version_at_submit
    click_on "Create Lead"

    assert_text "Lead was successfully created"
    click_on "Back"
  end

  test "should update Lead" do
    visit lead_url(@lead)
    click_on "Edit", match: :first

    select @lead.campaign.title, from: "Campaign"
    select @lead.landing_page.headline, from: "Landing page"
    fill_in "Public", with: @lead.public_id
    fill_in "Name", with: @lead.name
    fill_in "Email ciphertext", with: @lead.email_ciphertext
    fill_in "Phone ciphertext", with: @lead.phone_ciphertext
    check "Marketing consent" if @lead.marketing_consent
    fill_in "Consent source", with: @lead.consent_source
    fill_in "Privacy policy version", with: @lead.privacy_policy_version
    fill_in "Data", with: @lead.data.to_json
    fill_in "Utm source", with: @lead.utm_source
    fill_in "Utm medium", with: @lead.utm_medium
    fill_in "Utm campaign", with: @lead.utm_campaign
    fill_in "Utm term", with: @lead.utm_term
    fill_in "Utm content", with: @lead.utm_content
    fill_in "Gclid", with: @lead.gclid
    fill_in "Fbclid", with: @lead.fbclid
    fill_in "Msclkid", with: @lead.msclkid
    fill_in "Referrer url", with: @lead.referrer_url
    fill_in "Landing url", with: @lead.landing_url
    fill_in "User agent", with: @lead.user_agent
    fill_in "Ip address", with: @lead.ip_address
    fill_in "Referral code", with: @lead.referral_code
    fill_in "Idempotency key", with: @lead.idempotency_key
    fill_in "Schema version at submit", with: @lead.schema_version_at_submit
    click_on "Update Lead"

    assert_text "Lead was successfully updated"
    click_on "Back"
  end

  test "should destroy Lead" do
    visit lead_url(@lead)
    accept_confirm { click_on "Delete", match: :first }

    assert_text "Lead was successfully destroyed"
  end
end
