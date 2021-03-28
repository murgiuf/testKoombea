class AddEstadoToContacto < ActiveRecord::Migration[5.2]
  def change
    add_column :contactos, :estado, :integer
  end
end
