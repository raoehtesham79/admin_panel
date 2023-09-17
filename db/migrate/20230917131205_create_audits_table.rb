class CreateAuditsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :audits do |t|
      t.string :object_id
      t.string :action_name
      t.string :object_type
      t.string :performed_by_id
      t.string :performed_by
      t.json :data

      t.timestamps
    end
  end
end
