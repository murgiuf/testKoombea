class CreateCargas < ActiveRecord::Migration[5.2]
  def change
    create_table :cargas do |t|
      t.references :user, foreign_key: true
      t.string :archivo
      t.integer :estado

      t.timestamps
    end
  end
end
