class RemoveCompanyIdFromTeam < ActiveRecord::Migration[7.0]
  def change
    remove_column :teams, :company_id, :uuid
  end
end
