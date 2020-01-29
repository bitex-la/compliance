class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :verify_request, except: [:index, :create, :new, :batch_action]

  private

  def set_current_user
    if current_admin_user.nil? 
      authenticate_with_http_token do |token, options|
        AdminUser.current_admin_user = AdminUser.find_by(api_token: token)
      end
    else
      AdminUser.current_admin_user = current_admin_user
    end
  end

  def verify_request
    current_admin_user = AdminUser.current_admin_user
    return if current_admin_user.nil?

    person_id = related_person.to_s
    return if person_id.empty?

    set = current_admin_user.request_limit_set
    limit = current_admin_user.max_people_allowed

    if limit.nil?
      # si no hay limite configurado o existia y se modifico, no borro 
      # los usuarios rechazados para que puedan consultarse en el admin 
      # hasta que expiren. solo incremento el score de los usuarios permitidos.
      set.increment person_id
    else
      counter = current_admin_user.request_limit_counter
      rejected_set = current_admin_user.request_limit_rejected_set

      # si existe limite y el usuario ya esta incluido en el set de permitidos
      # incremento el score.
      if set.member? person_id
        set.increment person_id
      else
        # si no esta en el set valido si puedo agregarlo aumentando el contador atomicamente
        if counter.increment <= limit
          # si el valor incrementado es menor o igual al limite
          # incremento el score en el set de permitidos
          # si el usuario ya existia en el set decremento el contador para
          # dejar lugar a un futuro usuario.
          # el increment evita una condicion de carrera entre 2 request del mismo user_id
          unless set.increment(person_id) == 1
            counter.decrement
          end
          # elimino el usuario del set de rechazados si existe
          rejected_set.delete person_id
        else
          # si se supera el limite, decremento el contador para permitir
          # modificaciones dinamicas del limite e incremento el score en el set
          # de usuarios rechazados y retorno error 400.
          counter.decrement
          rejected_set.increment person_id
          render body: nil, status: 400
        end
      end
    end
  end
  
  def related_person
  end
end
