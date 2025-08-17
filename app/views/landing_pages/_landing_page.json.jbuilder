json.extract! landing_page, :id, :campaign_id, :slug, :headline, :subheadline, :body, :primary_cta_label, :primary_cta_url, :template, :status, :schema, :schema_version, :published_at, :created_at, :updated_at
json.url landing_page_url(landing_page, format: :json)
