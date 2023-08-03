class AddCompanyIdToTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :company_id, :uuid, index: true
  end
end
