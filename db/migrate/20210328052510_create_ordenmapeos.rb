class CreateOrdenmapeos < ActiveRecord::Migration[5.2]
  def change
    create_table :ordenmapeos do |t|
      t.references :user, foreign_key: true
      t.string :columna
      t.integer :orden

      t.timestamps
    end
  end
end
