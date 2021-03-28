module CargasHelper

  REGEX_TELF = /^(\(\+[0-9]{2}\)[" "])(\d{3})[(\-|" ")](\d{3})[(\-|" ")](\d{2})[(\-|" ")](\d{2})$/

  REGEX_PATTERN = /^[\w\s-]*$/i


  def h_import_contactos(file, omitir_cabeceras, carga)

    lista_errores = []
    lista_errores_f = []
    #d = DateTime.now
    #nombrelote = "#{file.original_filename}_#{origen}_#{d.strftime("%d%m%Y%H%M%S")}"
    #error_imp = nil
    error_linea = ""
    #lista_errores.push(nombrelote)
    lista_errores.push(file.original_filename)
    cantidad_errores = 0
    cantidad_inserts_ok = 0
    cantidad_inserts_error = 0



      dato_nombre = "row[#{get_orden_columna(current_user.id, Constantes::Mapeo::MAP_NOMBRE)}]"
      dato_nacimiento = "row[#{get_orden_columna(current_user.id, Constantes::Mapeo::MAP_NACIMIENTO)}]"
      dato_telefono = "row[#{get_orden_columna(current_user.id, Constantes::Mapeo::MAP_TELEFONO)}]"
      dato_direccion = "row[#{get_orden_columna(current_user.id, Constantes::Mapeo::MAP_DIRECCION)}]"
      dato_tarjeta = "row[#{get_orden_columna(current_user.id, Constantes::Mapeo::MAP_TARJETA)}]"
      dato_email = "row[#{get_orden_columna(current_user.id, Constantes::Mapeo::MAP_EMAIL)}]"


      CSV.foreach(file.path, encoding:'iso-8859-1:utf-8').with_index do |row, pos|

          next if omitir_cabeceras && pos == 0
          is_contacto_ok = true

            nombre = eval(dato_nombre)
            nacimiento = eval(dato_nacimiento)
            telefono = eval(dato_telefono)
            direccion = eval(dato_direccion)
            tarjeta = eval(dato_tarjeta)
            email = eval(dato_email)

            nombre = nombre.blank? ? nombre : nombre.strip
            nacimiento = nacimiento.blank? ? nacimiento : nacimiento.strip
            telefono = telefono.blank? ? telefono : telefono.strip
            direccion = direccion.blank? ? direccion : direccion.strip
            tarjeta = tarjeta.blank? ? tarjeta : tarjeta.strip
            email = email.blank? ? email : email.strip

            val_nombre = h_valida_nombre(nombre)
            val_nacimiento = h_valida_nacimiento(nacimiento)
            val_telefono = h_valida_telefono(telefono)
            val_direccion = h_valida_direccion(direccion)
            val_tarjeta = h_valida_tarjeta(tarjeta)
            val_email = h_valida_email(email)

            if val_nombre != 'ok'
              is_contacto_ok = false
            end

            if !val_nacimiento
              is_contacto_ok = false
            end

            if val_telefono != "ok"
              is_contacto_ok = false
            end

            if val_direccion != "ok"
              is_contacto_ok = false
            end

            if val_tarjeta == "tarjeta inválida"
              is_contacto_ok = false
            end

            if  val_email != "ok"
              is_contacto_ok = false
            end

            if is_contacto_ok
              contacto = Contacto.create!(nombre: nombre,
                                          nacimiento: nacimiento,
                                          telefono: telefono,
                                          direccion: direccion,
                                          tarjeta: Contacto.encripta_tarjeta(tarjeta),
                                          franquicia: val_tarjeta,
                                          email: email,
                                          carga: carga,
                                          estado: 1)
              cantidad_inserts_ok += 1
            else
              contacto = Contacto.create!(nombre: "#{nombre} => #{val_nombre}",
                                          nacimiento: "#{nacimiento} => #{val_nacimiento}",
                                          telefono: " #{telefono} => #{val_telefono}",
                                          direccion: " #{direccion} => #{val_direccion}",
                                          tarjeta:  "#{Contacto.encripta_tarjeta(tarjeta)}",
                                          email:  "#{email} => #{val_email}",
                                          carga: carga,
                                          estado: 0)
              cantidad_inserts_error += 1
            end
      end

      mi_estado =  cantidad_inserts_ok > 0 ? Constantes::Cargas::TERMINADO : Constantes::Cargas::FALLIDO
      carga.estado = mi_estado
      carga.total = cantidad_inserts_ok + cantidad_inserts_error
      carga.cargado = cantidad_inserts_ok
      carga.rechazado = cantidad_inserts_error
      carga.save
      return lista_errores
  end

  def h_valida_telefono(telefono)
    is_valido =  h_valida_telefono_aux(telefono) ? true : false

    if !is_valido
      return "Teléfono no valido, utilizar formatos (+00) 000 000 00 00 ó (+00) 000-000-00-00"
    end
    return "ok"
  end

  def  h_valida_direccion(direccion)
    if direccion.blank?
      return "dirección vacía"
    end
    return "ok"
  end


  def h_valida_tarjeta(tarjeta)
    bin = CreditCardBin.new(tarjeta.to_s)

    return bin.brand

  rescue
    return "tarjeta inválida"
  end

  def  h_valida_email(email)
    is_formato_valido =  is_email_valid_aux(email) ? true: false

    if !is_formato_valido
      return "Error email invalido"
    end

    query = "select count(*) from contactos cc, cargas ca, users uu
                                  where 1=1
                                  and cc.estado = 1
                                  and cc.email = '#{email}'
                                  and cc.carga_id = ca.id
                                  and ca.user_id = uu.id
                                  and uu.id = #{current_user.id}
                                  "
    cantidad = ActiveRecord::Base.connection.execute(query).getvalue(0,0)

    if cantidad.to_i > 0
      return "Error, correo ya asociado para el usuario #{current_user.email}"
    end

    return "ok"
  end

  REGEX_EMAIL = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  def is_email_valid_aux email
    email =~REGEX_EMAIL
  end


    def h_valida_nacimiento(p_nacimiento)
       parseable1 = Date.strptime(p_nacimiento, '%Y%m%d') rescue false

       if parseable1
         return true
       end

       parseable2 = Date.strptime(p_nacimiento, '%F') rescue false
       if parseable2
         return true
       end

       return false
    end

   def h_valida_nombre(p_nombre)

     if p_nombre.blank?
       return "Nombre vacío"
     end

     is_valido =  h_valida_nombre_aux(p_nombre) ? true : false

     if !is_valido
      return  "Nombre inválido"
     end

     return "ok"
   end

  def h_valida_nombre_aux(p_nombre)
    p_nombre =~REGEX_PATTERN
  end

  def h_valida_telefono_aux(telefono)
    telefono =~REGEX_TELF
  end

  def h_mira_si_tiene_mapeo(user_id)
    query = "Select count(*) from ordenmapeos where user_id = #{user_id}"

    if ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_i == 0
      set_default_map(user_id)
    end
  end

  def set_default_map(user_id)
    Ordenmapeo.create!(user_id: user_id, columna: Constantes::Mapeo::MAP_NOMBRE, orden: 0 )
    Ordenmapeo.create!(user_id: user_id, columna: Constantes::Mapeo::MAP_NACIMIENTO, orden: 1 )
    Ordenmapeo.create!(user_id: user_id, columna: Constantes::Mapeo::MAP_TELEFONO, orden: 2 )
    Ordenmapeo.create!(user_id: user_id, columna: Constantes::Mapeo::MAP_DIRECCION, orden: 3 )
    Ordenmapeo.create!(user_id: user_id, columna: Constantes::Mapeo::MAP_TARJETA, orden: 4 )
    Ordenmapeo.create!(user_id: user_id, columna: Constantes::Mapeo::MAP_EMAIL, orden: 5 )
  end

  def get_orden_columna(user_id, columna)
    query = " select orden from ordenmapeos om where 1=1
                            and user_id = #{user_id}
                            and columna = '#{columna}'"

     return ActiveRecord::Base.connection.execute(query).getvalue(0,0).to_i
  end



end
