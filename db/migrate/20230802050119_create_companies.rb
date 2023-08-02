class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies, id: :uuid do |t|
      t.string :name, null: false
      t.uuid :owner_id, null: false

      t.timestamps
    end

    add_index :companies, :name, unique: true
  end
end
