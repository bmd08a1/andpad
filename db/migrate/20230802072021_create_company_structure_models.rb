class CreateCompanyStructureModels < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.uuid :company_id
      t.string :name
      t.uuid :manager_id, index: true
    end

    create_table :members do |t|
      t.uuid :user_id, index: true
      t.references :team
    end
  end
end
