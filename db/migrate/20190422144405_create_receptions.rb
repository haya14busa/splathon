class CreateReceptions < ActiveRecord::Migration[5.1]
  def change
    create_table :receptions do |t|
      t.references :participant, foreign_key: true
      t.timestamps
    end
  end
end
