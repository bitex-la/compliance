class RiskArgentinaState
  include StaticModels::Model
  
  static_models_dense [
    [:id, :code,                :risk,   :value],
    [1,   :santa_cruz,          :high,   45],
    [2,   :tierra_del_fuego,    :high,   40],
    [3,   :entre_rios,          :high,   36],
    [4,   :chubut,              :high,   35],
    [5,   :salta,               :high,   33],
    [6,   :buenos_aires,        :high,   31], 
    [7,   :misiones,            :medium, 29],
    [8,   :mendoza,             :medium, 27],
    [9,   :santa_fe,            :medium, 27],
    [10,  :formosa,             :medium, 26],
    [11,  :neuquen,             :medium, 25], 
    [12,  :jujuy,               :medium, 22],
    [13,  :cordoba,             :medium, 20],
    [14,  :catamarca,           :medium, 18],
    [15,  :corrientes,          :medium, 18],
    [16,  :rio_negro,           :medium, 18],
    [17,  :chaco,               :low,    16],
    [18,  :la_rioja,            :low,    15],
    [19,  :san_juan,            :low,    15],
    [20,  :san_luis,            :low,    14],
    [21,  :tucuman,             :low,    13],
    [22,  :la_pampa,            :low,    11],
    [23,  :santiago_del_estero, :low,    11],
    [24,  :ciudad_autonoma_de_buenos_aires, :low, 15],
  ]

  def risk_value
    value
  end
end
