class Currency 
  include StaticModels::Model

  static_models_dense [
    [:id, :code, :name,                :decimals ],
    [1,   :btc,  'bitcoin',            4         ],
    [2,   :ltc,  'litecoin',           4         ],
    [3,   :bch,  'bcash',              4         ],
    [4,   :usd,  'us_dollar',          2         ],
    [5,   :ars,  'argentine_peso',     2         ],
    [6,   :uyu,  'uruguayan_peso',     2         ],
    [7,   :eur,  'euro',               2         ],
    [8,   :clp,  'chilean_peso',       2         ],
    [9,   :pen,  'peruvian_sol',       2         ],
    [10,  :brl,  'brazilian_real',     2         ],
    [11,  :cop,  'colombian_peso',     2         ],
    [12,  :mxn,  'mexican_peso',       2         ],
    [13,  :pyg,  'paraguayan_guarani', 2         ],
    [14,  :cny,  'chinese_yuan',       2         ],
    [15,  :inr,  'indian_rupee',       2         ],
    [16,  :vef,  'venezuelan_bolivar', 2         ],
  ]
end