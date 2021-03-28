json.extract! contacto, :id, :carga_id, :nombre, :nacimiento, :telefono, :direccion, :tarjeta, :franquicia, :email, :created_at, :updated_at
json.url contacto_url(contacto, format: :json)
