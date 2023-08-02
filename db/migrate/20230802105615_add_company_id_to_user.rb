class AddCompanyIdToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_id, :uuid, null: false
  end
end
