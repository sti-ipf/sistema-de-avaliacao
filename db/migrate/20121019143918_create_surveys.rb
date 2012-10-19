class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.text :observation
      t.references :service_level
      t.references :school
      t.references :segment
      t.string :author

      t.timestamps
    end
  end

  def self.down
    drop_table :surveys
  end
end
