class RiskNationality
  include StaticModels::Model
   
  static_models_dense [
    [:id, :code, :risk,    :value],
    [1,   :AF,   :high,    33],
    [2,   :AL,   :medium,  27],
    [3,   :DE,   :low,     7],
    [4,   :AO,   :high,    31],
    [5,   :AG,   :medium,  29],
    [6,   :SA,   :medium,  17],
    [7,   :DZ,   :medium,  30],
    [8,   :AR,   :medium,  29],
    [9,   :AM,   :medium,  18],
    [10,  :AW,   :medium,  25],
    [11,  :AU,   :low,     13],
    [12,  :AT,   :low,     7],
    [13,  :AZ,   :medium,  19],
    [14,  :BS,   :medium,  28],
    [15,  :BD,   :medium,  30],
    [16,  :BB,   :medium,  25],
    [17,  :BH,   :medium,  24],
    [18,  :BE,   :low,     7],
    [19,  :BZ,   :medium,  26],
    [20,  :BJ,   :medium,  30],
    [21,  :BM,   :medium,  25],
    [22,  :BY,   :high,    32],
    [23,  :MM,   :high,    40],
    [24,  :BO,   :medium,  30],
    [25,  :BA,   :high,    32],
    [26,  :BW,   :high,    36],
    [27,  :BR,   :medium,  18],
    [28,  :BN,   :medium,  24],
    [29,  :BG,   :medium,  16],
    [30,  :BF,   :high,    33],
    [31,  :BI,   :high,    38],
    [32,  :BT,   :medium,  30],
    [33,  :CV,   :medium,  27],
    [34,  :KH,   :high,    40],
    [35,  :CM,   :medium,  24],
    [36,  :CA,   :low,     10],
    [37,  :TD,   :high,    35],
    [38,  :CL,   :low,     11],
    [39,  :CN,   :medium,  19],
    [40,  :CY,   :medium,  16],
    [41,  :CO,   :low,     14],
    [42,  :KP,   :high,    45],
    [43,  :KR,   :low,     12],
    [44,  :CI,   :medium,  30],
    [45,  :CR,   :low,     14],
    [46,  :HR,   :low,     13],
    [47,  :CU,   :high,    32],
    [48,  :DK,   :low,     5],
    [49,  :DM,   :medium,  22],
    [50,  :EC,   :medium,  28],
    [51,  :EG,   :medium,  28],
    [52,  :SV,   :medium,  18],
    [53,  :AE,   :medium,  20],
    [54,  :SK,   :low,     12],
    [55,  :SI,   :low,     7],
    [56,  :ES,   :low,     8],
    [57,  :US,   :low,     11],
    [58,  :EE,   :low,     5],
    [59,  :ET,   :high,    33],
    [60,  :PH,   :medium,  29],
    [61,  :FI,   :low,     5],
    [62,  :FR,   :low,     7],
    [63,  :GM,   :medium,  28],
    [64,  :GE,   :medium,  16],
    [65,  :GH,   :medium,  26],
    [66,  :GD,   :medium,  22],
    [67,  :GR,   :low,     9],
    [68,  :GT,   :medium,  19],
    [69,  :GQ,   :high,    35],
    [70,  :GY,   :medium,  28],
    [71,  :HT,   :high,    33],
    [72,  :NL,   :low,     6],
    [73,  :HN,   :medium,  30],
    [74,  :HK,   :low,     14],
    [75,  :HU,   :low,     11],
    [76,  :IN,   :medium,  18],
    [77,  :ID,   :medium,  17],
    [78,  :IR,   :high,    44],
    [79,  :IQ,   :high,    35],
    [80,  :IE,   :low,     7],
    [81,  :IS,   :low,     8],
    [82,  :KY,   :high,    34],
    [83,  :CK,   :medium,  23],
    [84,  :MH,   :medium,  29],
    [85,  :TC,   :medium,  25],
    [86,  :VI,   :high,    40],
    [87,  :VG,   :medium,  30],
    [88,  :IL,   :low,     11],
    [89,  :IT,   :low,     9],
    [90,  :JM,   :medium,  27],
    [91,  :JP,   :low,     11],
    [92,  :JO,   :high,    31],
    [93,  :KZ,   :medium,  18],
    [94,  :KE,   :high,    31],
    [95,  :KG,   :medium,  30],
    [96,  :KW,   :medium,  23],
    [97,  :LA,   :high,    32],
    [98,  :LS,   :high,    33],
    [99,  :LV,   :low,     8],
    [100, :LB,   :medium,  23],
    [101, :LR,   :high,    37],
    [102, :LY,   :medium,  30],
    [103, :LT,   :low,     8],
    [104, :LU,   :low,     7],
    [105, :MO,   :medium,  22],
    [106, :MK,   :medium,  21],
    [107, :MG,   :high,    34],
    [108, :MY,   :medium,  17],
    [109, :MV,   :high,    37],
    [110, :MT,   :medium,  17],
    [111, :MA,   :medium,  22],
    [112, :MU,   :medium,  29],
    [113, :MR,   :high,    34],
    [114, :MX,   :medium,  19],
    [115, :MD,   :medium,  19],
    [116, :MN,   :high,    33],
    [117, :ME,   :medium,  26],
    [118, :MZ,   :high,    32],
    [119, :NA,   :high,    35],
    [120, :NP,   :high,    33],
    [121, :NI,   :high,    40],
    [122, :NE,   :high,    34],
    [123, :NG,   :medium,  21],
    [124, :NO,   :low,     7],
    [125, :NZ,   :low,     8],
    [126, :OM,   :high,    38],
    [127, :PK,   :medium,  28],
    [128, :PA,   :high,    36],
    [129, :PG,   :high,    34],
    [130, :PY,   :medium,  30],
    [131, :PE,   :medium,  18],
    [132, :PL,   :low,     9],
    [133, :PT,   :low,     8],
    [134, :QA,   :medium,  16],
    [135, :GB,   :low,     10],
    [136, :CZ,   :low,     9],
    [137, :CD,   :high,    35],
    [138, :DO,   :medium,  19],
    [139, :GN,   :high,    34],
    [140, :RW,   :medium,  26],
    [141, :RO,   :low,     14],
    [142, :RU,   :medium,  20],
    [143, :WS,   :high,    32],
    [144, :VC,   :medium,  19],
    [145, :LC,   :medium,  22],
    [146, :ST,   :high,    32],
    [147, :SN,   :medium,  20],
    [148, :RS,   :medium,  18],
    [149, :SC,   :medium,  26],
    [150, :SL,   :high,    31],
    [151, :SG,   :low,     13],
    [152, :SY,   :high,    44],
    [153, :SO,   :high,    36],
    [154, :LK,   :medium,  29],
    [155, :SZ,   :high,    37],
    [156, :ZA,   :medium,  17],
    [157, :SD,   :high,    35],
    [158, :SE,   :low,     5],
    [159, :CH,   :low,     8],
    [160, :SR,   :high,    32],
    [161, :TJ,   :medium,  30],
    [162, :TH,   :high,    33],
    [163, :TW,   :medium,  18],
    [164, :TZ,   :medium,  29],
    [165, :TL,   :high,    33],
    [166, :TG,   :high,    34],
    [167, :TT,   :high,    34],
    [168, :TN,   :medium,  18],
    [169, :TM,   :medium,  25],
    [170, :TR,   :medium,  19],
    [171, :UA,   :medium,  19],
    [172, :UG,   :high,    32],
    [173, :UY,   :low,     14],
    [174, :UZ,   :medium,  30],
    [175, :VU,   :high,    34],
    [176, :VE,   :medium,  22],
    [177, :VN,   :medium,  30],
    [178, :YE,   :high,    41],
    [179, :ZM,   :high,    33],
    [180, :ZW,   :high,    39]
  ]

  def risk_value
    value
  end
end
