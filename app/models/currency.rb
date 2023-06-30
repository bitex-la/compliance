class Currency 
  include StaticModels::Model

  static_models_dense [
    [:id, :code,  :name,                     :decimals,  :type],
    [1,   :btc,   'bitcoin',                 4,          :crypto],
    [2,   :ltc,   'litecoin',                4,          :crypto],
    [3,   :bch,   'bcash',                   4,          :crypto],
    [4,   :usd,   'us_dollar',               2,          :fiat],
    [5,   :ars,   'argentine_peso',          2,          :fiat],
    [6,   :uyu,   'uruguayan_peso',          2,          :fiat],
    [7,   :eur,   'euro',                    2,          :fiat],
    [8,   :clp,   'chilean_peso',            2,          :fiat],
    [9,   :pen,   'peruvian_sol',            2,          :fiat],
    [10,  :brl,   'brazilian_real',          2,          :fiat],
    [11,  :cop,   'colombian_peso',          2,          :fiat],
    [12,  :mxn,   'mexican_peso',            2,          :fiat],
    [13,  :pyg,   'paraguayan_guarani',      2,          :fiat],
    [14,  :cny,   'chinese_yuan',            2,          :fiat],
    [15,  :inr,   'indian_rupee',            2,          :fiat],
    [16,  :vef,   'venezuelan_bolivar',      2,          :fiat],
    [17,  :aud,   'australian_dollar',       2,          :fiat],
    [18,  :gbp,   'pound_sterling',          2,          :fiat],
    [19,  :hkd,   'hong_kong_dollar',        2,          :fiat],
    [20,  :bob,   'bolivian_peso',           2,          :fiat],
    [21,  :ada,   'ada',                     8,          :crypto],
    [22,  :bnb,   'binance_coin',            8,          :crypto],
    [23,  :dai,   'dai',                     8,          :crypto],
    [24,  :eth,   'ethereum',                8,          :crypto],
    [25,  :link,  'link',                    8,          :crypto],
    [26,  :sushi, 'sushi',                   8,          :crypto],
    [27,  :uni,   'uni',                     8,          :crypto],
    [28,  :usdt,  'usd_tether',              8,          :crypto],
    [29,  :ftt,   'ftt',                     8,          :crypto],
    [30,  :yfi,   'yfi',                     8,          :crypto],
    [31,  :dot,   'dot',                     8,          :crypto],
    [32,  :doge,  'doge',                    8,          :crypto],
    [33,  :soya,  'soya',                    8,          :crypto],
    [34,  :usdc,  'usdc',                    2,          :crypto],
    [35,  :sol,   'sol',                     8,          :crypto],
    [36,  :cora,  'cora',                    8,          :crypto],
    [37,  :brz,   'brazilian_digital_token', 8,          :crypto],
    [38,  :shib,  'shiba_inu',               8,          :crypto],
    [39,  :mana,  'mana',                    8,          :crypto],
    [40,  :chz,   'chiliz',                  8,          :crypto],
    [41,  :xlm,   'stellar',                 8,          :crypto],
    [42,  :xrp,   'ripple',                  8,          :crypto],
  ]

  def is_fiat?
    type == :fiat
  end
end
