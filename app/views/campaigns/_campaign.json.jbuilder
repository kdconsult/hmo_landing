json.extract! campaign, :id, :title, :slug, :body, :start_date, :end_date, :active, :created_at, :updated_at
json.url campaign_url(campaign, format: :json)
