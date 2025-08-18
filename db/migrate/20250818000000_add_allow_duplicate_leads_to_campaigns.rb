class AddAllowDuplicateLeadsToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :allow_duplicate_leads, :boolean, default: false, null: false
  end
end
