class CreateContactos < ActiveRecord::Migration[5.2]
  def change
    create_table :contactos do |t|
      t.references :carga, foreign_key: true
      t.string :nombre
      t.date :nacimiento
      t.string :telefono
      t.string :direccion
      t.string :tarjeta
      t.string :franquicia
      t.string :email

      t.timestamps
    end
  end
end
