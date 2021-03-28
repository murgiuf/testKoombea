class Carga < ApplicationRecord
  belongs_to :user

  def estado_str
    estado = self.estado

    case estado
      when Constantes::Cargas::ESPERA
      return Constantes::Cargas::ESPERA_STR
      when Constantes::Cargas::PROCESANDO
      return Constantes::Cargas::PROCESANDO_STR
      when Constantes::Cargas::FALLIDO
      return Constantes::Cargas::FALLIDO_STR
      when Constantes::Cargas::TERMINADO
      return Constantes::Cargas::TERMINADO_STR
    else
      return "estado invalido"
    end
  end
end
