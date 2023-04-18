class RiskActivity
  include StaticModels::Model
  
  static_models_dense [
    [:id,  :code,   :risk,    :value],
    [1,    :a11111, :medium,  40],
    [2,    :a11112, :medium,  40],
    [3,    :a11119, :medium,  40],
    [4,    :a11121, :medium,  40],
    [5,    :a11129, :medium,  40],
    [6,    :a11130, :medium,  40],
    [7,    :a11211, :medium,  40],
    [8,    :a11291, :medium,  40],
    [9,    :a11299, :medium,  40],
    [10,   :a11310, :medium,  40],
    [11,   :a11321, :medium,  40],
    [12,   :a11329, :medium,  40],
    [13,   :a11331, :medium,  40],
    [14,   :a11341, :medium,  40],
    [15,   :a11342, :medium,  40],
    [16,   :a11400, :medium,  40],
    [17,   :a11501, :medium,  40],
    [18,   :a11509, :medium,  40],
    [19,   :a11911, :medium,  40],
    [20,   :a11912, :medium,  40],
    [21,   :a11990, :medium,  40],
    [22,   :a12110, :medium,  40],
    [23,   :a12121, :medium,  40],
    [24,   :a12200, :medium,  40],
    [25,   :a12311, :medium,  40],
    [26,   :a12319, :medium,  40],
    [27,   :a12320, :medium,  40],
    [28,   :a12410, :medium,  40],
    [29,   :a12420, :medium,  40],
    [30,   :a12490, :medium,  40],
    [31,   :a12510, :medium,  40],
    [32,   :a12590, :medium,  40],
    [33,   :a12600, :medium,  40],
    [34,   :a12701, :medium,  40],
    [35,   :a12709, :medium,  40],
    [36,   :a12800, :medium,  40],
    [37,   :a12900, :medium,  40],
    [38,   :a13011, :low,     20],
    [39,   :a13012, :low,     20],
    [40,   :a13013, :low,     20],
    [41,   :a13019, :low,     20],
    [42,   :a13020, :low,     20],
    [43,   :a14113, :medium,  40],
    [44,   :a14114, :medium,  40],
    [45,   :a14115, :medium,  40],
    [46,   :a14121, :medium,  40],
    [47,   :a14211, :medium,  40],
    [48,   :a14300, :medium,  40],
    [49,   :a14410, :medium,  40],
    [50,   :a14420, :medium,  40],
    [51,   :a14430, :medium,  40],
    [52,   :a14440, :medium,  40],
    [53,   :a14510, :medium,  40],
    [54,   :a14520, :medium,  40],
    [55,   :a14610, :medium,  40],
    [56,   :a14620, :medium,  40],
    [57,   :a14710, :medium,  40],
    [58,   :a14720, :medium,  40],
    [59,   :a14810, :medium,  40],
    [60,   :a14820, :medium,  40],
    [61,   :a14910, :medium,  40],
    [62,   :a14920, :medium,  40],
    [63,   :a14930, :medium,  40],
    [64,   :a14990, :medium,  40],
    [65,   :a16111, :low,     20],
    [66,   :a16112, :low,     20],
    [67,   :a16113, :low,     20],
    [68,   :a16119, :low,     20],
    [69,   :a16120, :low,     20],
    [70,   :a16130, :low,     20],
    [71,   :a16140, :low,     20],
    [72,   :a16150, :low,     20],
    [73,   :a16190, :high,    60],
    [74,   :a16210, :low,     20],
    [75,   :a16220, :low,     20],
    [76,   :a16230, :low,     20],
    [77,   :a16291, :low,     20],
    [78,   :a16292, :low,     20],
    [79,   :a16299, :low,     20],
    [80,   :a17010, :low,     20],
    [81,   :a17020, :low,     20],
    [82,   :a21010, :low,     20],
    [83,   :a21020, :low,     20],
    [84,   :a21030, :low,     20],
    [85,   :a22010, :low,     20],
    [86,   :a22020, :low,     20],
    [87,   :a24010, :low,     20],
    [88,   :a24020, :low,     20],
    [89,   :a31110, :low,     20],
    [90,   :a31120, :low,     20],
    [91,   :a31130, :low,     20],
    [92,   :a31200, :low,     20],
    [93,   :a31300, :low,     20],
    [94,   :a32000, :low,     20],
    [95,   :a51000, :medium,  40],
    [96,   :a52000, :medium,  40],
    [97,   :a61000, :medium,  40],
    [98,   :a62000, :medium,  40],
    [99,   :a71000, :medium,  40],
    [100,  :a72100, :medium,  40],
    [101,  :a72910, :medium,  40],
    [102,  :a72990, :medium,  40],
    [103,  :a81100, :medium,  40],
    [104,  :a81200, :medium,  40],
    [105,  :a81300, :high,    60],
    [106,  :a81400, :high,    60],
    [107,  :a89110, :high,    60],
    [108,  :a89120, :high,    60],
    [109,  :a89200, :high,    60],
    [110,  :a89300, :high,    60],
    [111,  :a89900, :high,    60],
    [112,  :a91000, :low,     20],
    [113,  :a99000, :low,     20],
    [114,  :a101011, :low,    20],
    [115,  :a101012, :low,    20],
    [116,  :a101013, :low,    20],
    [117,  :a101020, :low,    20],
    [118,  :a101030, :low,    20],
    [119,  :a101040, :medium, 40],
    [120,  :a101091, :low,    20],
    [121,  :a101099, :medium, 40],
    [122,  :a102001, :low,    20],
    [123,  :a102002, :low,    20],
    [124,  :a102003, :low,    20],
    [125,  :a103011, :low,    20],
    [126,  :a103012, :low,    20],
    [127,  :a103020, :low,    20],
    [128,  :a103030, :low,    20],
    [129,  :a103091, :low,    20],
    [130,  :a103099, :low,    20],
    [131,  :a104011, :low,    20],
    [132,  :a104012, :low,    20],
    [133,  :a104013, :low,    20],
    [134,  :a104020, :low,    20],
    [135,  :a105010, :low,    20],
    [136,  :a105020, :low,    20],
    [137,  :a105030, :low,    20],
    [138,  :a105090, :low,    20],
    [139,  :a106110, :low,    20],
    [140,  :a106120, :low,    20],
    [141,  :a106131, :low,    20],
    [142,  :a106139, :low,    20],
    [143,  :a106200, :low,    20],
    [144,  :a107110, :low,    20],
    [145,  :a107121, :low,    20],
    [146,  :a107129, :low,    20],
    [147,  :a107200, :low,    20],
    [148,  :a107301, :low,    20],
    [149,  :a107309, :low,    20],
    [150,  :a107410, :low,    20],
    [151,  :a107420, :low,    20],
    [152,  :a107500, :low,    20],
    [153,  :a107911, :low,    20],
    [154,  :a107912, :low,    20],
    [155,  :a107920, :low,    20],
    [156,  :a107930, :low,    20],
    [157,  :a107991, :low,    20],
    [158,  :a107992, :low,    20],
    [159,  :a107999, :low,    20],
    [160,  :a108000, :low,    20],
    [161,  :a109000, :low,    20],
    [162,  :a110100, :medium, 40],
    [163,  :a110211, :medium, 40],
    [164,  :a110212, :medium, 40],
    [165,  :a110290, :medium, 40],
    [166,  :a110300, :medium, 40],
    [167,  :a110411, :medium, 40],
    [168,  :a110412, :medium, 40],
    [169,  :a110420, :medium, 40],
    [170,  :a110491, :medium, 40],
    [171,  :a110492, :medium, 40],
    [172,  :a120010, :medium, 40],
    [173,  :a120091, :medium, 40],
    [174,  :a120099, :medium, 40],
    [175,  :a131110, :medium, 40],
    [176,  :a131120, :medium, 40],
    [177,  :a131131, :medium, 40],
    [178,  :a131132, :medium, 40],
    [179,  :a131139, :medium, 40],
    [180,  :a131201, :medium, 40],
    [181,  :a131202, :medium, 40],
    [182,  :a131209, :medium, 40],
    [183,  :a131300, :medium, 40],
    [184,  :a139100, :medium, 40],
    [185,  :a139201, :medium, 40],
    [186,  :a139202, :medium, 40],
    [187,  :a139203, :medium, 40],
    [188,  :a139204, :medium, 40],
    [189,  :a139209, :medium, 40],
    [190,  :a139300, :medium, 40],
    [191,  :a139400, :medium, 40],
    [192,  :a139900, :medium, 40],
    [193,  :a141110, :medium, 40],
    [194,  :a141120, :medium, 40],
    [195,  :a141130, :medium, 40],
    [196,  :a141140, :medium, 40],
    [197,  :a141191, :medium, 40],
    [198,  :a141199, :medium, 40],
    [199,  :a141201, :medium, 40],
    [200,  :a141202, :medium, 40],
    [201,  :a142000, :medium, 40],
    [202,  :a143010, :medium, 40],
    [203,  :a143020, :medium, 40],
    [204,  :a149000, :medium, 40],
    [205,  :a151100, :medium, 40],
    [206,  :a151200, :medium, 40],
    [207,  :a152011, :medium, 40],
    [208,  :a152021, :medium, 40],
    [209,  :a152031, :medium, 40],
    [210,  :a152040, :medium, 40],
    [211,  :a161001, :medium, 40],
    [212,  :a161002, :medium, 40],
    [213,  :a162100, :medium, 40],
    [214,  :a162201, :high,   60],
    [215,  :a162202, :high,   60],
    [216,  :a162300, :high,   60],
    [217,  :a162901, :high,   60],
    [218,  :a162902, :high,   60],
    [219,  :a162903, :high,   60],
    [220,  :a162909, :high,   60],
    [221,  :a170101, :high,   60],
    [222,  :a170102, :high,   60],
    [223,  :a170201, :high,   60],
    [224,  :a170202, :high,   60],
    [225,  :a170910, :high,   60],
    [226,  :a170990, :high,   60],
    [227,  :a181101, :high,   60],
    [228,  :a181109, :high,   60],
    [229,  :a181200, :high,   60],
    [230,  :a182000, :high,   60],
    [231,  :a191000, :high,   60],
    [232,  :a192000, :high,   60],
    [233,  :a201110, :high,   60],
    [234,  :a201120, :high,   60],
    [235,  :a201130, :high,   60],
    [236,  :a201140, :high,   60],
    [237,  :a201180, :high,   60],
    [238,  :a201190, :high,   60],
    [239,  :a201210, :high,   60],
    [240,  :a201220, :high,   60],
    [241,  :a201300, :high,   60],
    [242,  :a201401, :high,   60],
    [243,  :a201409, :high,   60],
    [244,  :a202101, :high,   60],
    [245,  :a202200, :high,   60],
    [246,  :a202311, :high,   60],
    [247,  :a202312, :high,   60],
    [248,  :a202320, :high,   60],
    [249,  :a202906, :high,   60],
    [250,  :a202907, :high,   60],
    [251,  :a202908, :high,   60],
    [252,  :a203000, :medium, 40],
    [253,  :a204000, :medium, 40],
    [254,  :a210010, :medium, 40],
    [255,  :a210020, :medium, 40],
    [256,  :a210030, :medium, 40],
    [257,  :a210090, :medium, 40],
    [258,  :a221110, :medium, 40],
    [259,  :a221120, :medium, 40],
    [260,  :a221901, :medium, 40],
    [261,  :a221909, :medium, 40],
    [262,  :a222010, :medium, 40],
    [263,  :a222090, :medium, 40],
    [264,  :a231010, :medium, 40],
    [265,  :a231020, :medium, 40],
    [266,  :a231090, :medium, 40],
    [267,  :a239100, :medium, 40],
    [268,  :a239201, :medium, 40],
    [269,  :a239202, :medium, 40],
    [270,  :a239209, :medium, 40],
    [271,  :a239310, :medium, 40],
    [272,  :a239391, :medium, 40],
    [273,  :a239399, :medium, 40],
    [274,  :a239410, :medium, 40],
    [275,  :a239421, :medium, 40],
    [276,  :a239422, :medium, 40],
    [277,  :a239510, :medium, 40],
    [278,  :a239591, :medium, 40],
    [279,  :a239592, :high,   60],
    [280,  :a239593, :high,   60],
    [281,  :a239600, :high,   60],
    [282,  :a239900, :high,   60],
    [283,  :a241001, :high,   60],
    [284,  :a241009, :high,   60],
    [285,  :a242010, :high,   60],
    [286,  :a242090, :high,   60],
    [287,  :a243100, :medium, 40],
    [288,  :a243200, :medium, 40],
    [289,  :a251101, :medium, 40],
    [290,  :a251102, :medium, 40],
    [291,  :a251200, :medium, 40],
    [292,  :a251300, :medium, 40],
    [293,  :a252000, :medium, 40],
    [294,  :a259100, :medium, 40],
    [295,  :a259200, :medium, 40],
    [296,  :a259301, :medium, 40],
    [297,  :a259302, :medium, 40],
    [298,  :a259309, :medium, 40],
    [299,  :a259910, :medium, 40],
    [300,  :a259991, :medium, 40],
    [301,  :a259992, :medium, 40],
    [302,  :a259993, :medium, 40],
    [303,  :a259999, :medium, 40],
    [304,  :a261000, :medium, 40],
    [305,  :a262000, :medium, 40],
    [306,  :a263000, :medium, 40],
    [307,  :a264000, :medium, 40],
    [308,  :a265101, :medium, 40],
    [309,  :a265102, :low,    20],
    [310,  :a265200, :low,    20],
    [311,  :a266010, :low,    20],
    [312,  :a266090, :low,    20],
    [313,  :a267001, :low,    20],
    [314,  :a267002, :low,    20],
    [315,  :a268000, :low,    20],
    [316,  :a271010, :low,    20],
    [317,  :a271020, :low,    20],
    [318,  :a272000, :low,    20],
    [319,  :a273110, :low,    20],
    [320,  :a273190, :low,    20],
    [321,  :a274000, :low,    20],
    [322,  :a275010, :low,    20],
    [323,  :a275091, :low,    20],
    [324,  :a275092, :low,    20],
    [325,  :a275099, :low,    20],
    [326,  :a279000, :low,    20],
    [327,  :a281100, :low,    20],
    [328,  :a281201, :low,    20],
    [329,  :a281301, :low,    20],
    [330,  :a281400, :low,    20],
    [331,  :a281500, :low,    20],
    [332,  :a281600, :low,    20],
    [333,  :a281700, :low,    20],
    [334,  :a281900, :low,    20],
    [335,  :a282110, :low,    20],
    [336,  :a282120, :low,    20],
    [337,  :a282130, :low,    20],
    [338,  :a282200, :low,    20],
    [339,  :a282300, :low,    20],
    [340,  :a282400, :high,   60],
    [341,  :a282500, :low,    20],
    [342,  :a282600, :low,    20],
    [343,  :a282901, :low,    20],
    [344,  :a282909, :low,    20],
    [345,  :a291000, :low,    20],
    [346,  :a292000, :low,    20],
    [347,  :a293011, :low,    20],
    [348,  :a293090, :low,    20],
    [349,  :a301100, :high,   60],
    [350,  :a301200, :high,   60],
    [351,  :a302000, :low,    20],
    [352,  :a303000, :low,    20],
    [353,  :a309100, :low,    20],
    [354,  :a309200, :low,    20],
    [355,  :a309900, :low,    20],
    [356,  :a310010, :low,    20],
    [357,  :a310020, :low,    20],
    [358,  :a310030, :low,    20],
    [359,  :a321011, :low,    20],
    [360,  :a321012, :low,    20],
    [361,  :a321020, :low,    20],
    [362,  :a322001, :low,    20],
    [363,  :a323001, :low,    20],
    [364,  :a324000, :low,    20],
    [365,  :a329010, :low,    20],
    [366,  :a329020, :low,    20],
    [367,  :a329030, :low,    20],
    [368,  :a329040, :low,    20],
    [369,  :a329090, :low,    20],
    [370,  :a331101, :low,    20],
    [371,  :a331210, :low,    20],
    [372,  :a331220, :low,    20],
    [373,  :a331290, :low,    20],
    [374,  :a331400, :low,    20],
    [375,  :a331900, :low,    20],
    [376,  :a332000, :low,    20],
    [377,  :a351110, :low,    20],
    [378,  :a351120, :low,    20],
    [379,  :a351130, :low,    20],
    [380,  :a351190, :low,    20],
    [381,  :a351201, :low,    20],
    [382,  :a351310, :low,    20],
    [383,  :a351320, :low,    20],
    [384,  :a352010, :low,    20],
    [385,  :a352020, :low,    20],
    [386,  :a353001, :low,    20],
    [387,  :a360010, :low,    20],
    [388,  :a360020, :low,    20],
    [389,  :a370000, :low,    20],
    [390,  :a381100, :low,    20],
    [391,  :a381200, :low,    20],
    [392,  :a382010, :low,    20],
    [393,  :a382020, :low,    20],
    [394,  :a390000, :low,    20],
    [395,  :a410011, :high,   60],
    [396,  :a410021, :high,   60],
    [397,  :a421000, :high,   60],
    [398,  :a422100, :high,   60],
    [399,  :a422200, :high,   60],
    [400,  :a429010, :high,   60],
    [401,  :a429090, :high,   60],
    [402,  :a431100, :high,   60],
    [403,  :a431210, :high,   60],
    [404,  :a432110, :low,    20],
    [405,  :a432190, :low,    20],
    [406,  :a432200, :low,    20],
    [407,  :a432910, :low,    20],
    [408,  :a432920, :low,    20],
    [409,  :a432990, :low,    20],
    [410,  :a433010, :medium, 40],
    [411,  :a433020, :low,    20],
    [412,  :a433030, :low,    20],
    [413,  :a433040, :low,    20],
    [414,  :a433090, :low,    20],
    [415,  :a439100, :high,   60],
    [416,  :a439910, :low,    20],
    [417,  :a439990, :high,   60],
    [418,  :a451110, :medium, 40],
    [419,  :a451190, :medium, 40],
    [420,  :a451210, :medium, 40],
    [421,  :a451290, :medium, 40],
    [422,  :a452101, :high,   60],
    [423,  :a452210, :low,    20],
    [424,  :a452220, :low,    20],
    [425,  :a452300, :medium, 40],
    [426,  :a452401, :low,    20],
    [427,  :a452500, :low,    20],
    [428,  :a452600, :low,    20],
    [429,  :a452700, :low,    20],
    [430,  :a452800, :low,    20],
    [431,  :a452910, :low,    20],
    [432,  :a452990, :low,    20],
    [433,  :a453100, :medium, 40],
    [434,  :a453210, :medium, 40],
    [435,  :a453220, :medium, 40],
    [436,  :a453291, :medium, 40],
    [437,  :a453292, :medium, 40],
    [438,  :a454010, :medium, 40],
    [439,  :a454020, :low,    20],
    [440,  :a461011, :medium, 40],
    [441,  :a461012, :medium, 40],
    [442,  :a461013, :medium, 40],
    [443,  :a461014, :medium, 40],
    [444,  :a461019, :medium, 40],
    [445,  :a461021, :medium, 40],
    [446,  :a461022, :medium, 40],
    [447,  :a461029, :medium, 40],
    [448,  :a461031, :medium, 40],
    [449,  :a461032, :medium, 40],
    [450,  :a461039, :high,   60],
    [451,  :a461040, :high,   60],
    [452,  :a461092, :high,   60],
    [453,  :a461093, :high,   60],
    [454,  :a461094, :medium, 40],
    [455,  :a461095, :medium, 40],
    [456,  :a461099, :medium, 40],
    [457,  :a462110, :medium, 40],
    [458,  :a462120, :medium, 40],
    [459,  :a462131, :medium, 40],
    [460,  :a462132, :medium, 40],
    [461,  :a462190, :medium, 40],
    [462,  :a462201, :medium, 40],
    [463,  :a462209, :medium, 40],
    [464,  :a463111, :medium, 40],
    [465,  :a463112, :medium, 40],
    [466,  :a463121, :medium, 40],
    [467,  :a463129, :medium, 40],
    [468,  :a463130, :medium, 40],
    [469,  :a463140, :medium, 40],
    [470,  :a463151, :medium, 40],
    [471,  :a463152, :medium, 40],
    [472,  :a463153, :medium, 40],
    [473,  :a463154, :medium, 40],
    [474,  :a463159, :medium, 40],
    [475,  :a463160, :medium, 40],
    [476,  :a463170, :medium, 40],
    [477,  :a463180, :medium, 40],
    [478,  :a463191, :medium, 40],
    [479,  :a463199, :medium, 40],
    [480,  :a463211, :medium, 40],
    [481,  :a463212, :medium, 40],
    [482,  :a463219, :medium, 40],
    [483,  :a463220, :medium, 40],
    [484,  :a463300, :medium, 40],
    [485,  :a464111, :medium, 40],
    [486,  :a464112, :medium, 40],
    [487,  :a464113, :medium, 40],
    [488,  :a464114, :medium, 40],
    [489,  :a464119, :medium, 40],
    [490,  :a464121, :medium, 40],
    [491,  :a464122, :medium, 40],
    [492,  :a464129, :medium, 40],
    [493,  :a464130, :medium, 40],
    [494,  :a464141, :medium, 40],
    [495,  :a464142, :medium, 40],
    [496,  :a464149, :medium, 40],
    [497,  :a464150, :medium, 40],
    [498,  :a464211, :medium, 40],
    [499,  :a464212, :medium, 40],
    [500,  :a464221, :medium, 40],
    [501,  :a464222, :medium, 40],
    [502,  :a464223, :medium, 40],
    [503,  :a464310, :medium, 40],
    [504,  :a464320, :medium, 40],
    [505,  :a464330, :medium, 40],
    [506,  :a464340, :medium, 40],
    [507,  :a464410, :medium, 40],
    [508,  :a464420, :medium, 40],
    [509,  :a464501, :medium, 40],
    [510,  :a464502, :medium, 40],
    [511,  :a464610, :medium, 40],
    [512,  :a464620, :medium, 40],
    [513,  :a464631, :medium, 40],
    [514,  :a464632, :medium, 40],
    [515,  :a464920, :medium, 40],
    [516,  :a464930, :medium, 40],
    [517,  :a464940, :medium, 40],
    [518,  :a464950, :medium, 40],
    [519,  :a464991, :medium, 40],
    [520,  :a464999, :medium, 40],
    [521,  :a465100, :medium, 40],
    [522,  :a465210, :medium, 40],
    [523,  :a465220, :medium, 40],
    [524,  :a465310, :medium, 40],
    [525,  :a465320, :medium, 40],
    [526,  :a465330, :medium, 40],
    [527,  :a465340, :medium, 40],
    [528,  :a465350, :medium, 40],
    [529,  :a465360, :medium, 40],
    [530,  :a465390, :medium, 40],
    [531,  :a465400, :medium, 40],
    [532,  :a465500, :medium, 40],
    [533,  :a465610, :medium, 40],
    [534,  :a465690, :medium, 40],
    [535,  :a465910, :medium, 40],
    [536,  :a465920, :medium, 40],
    [537,  :a465930, :medium, 40],
    [538,  :a465990, :medium, 40],
    [539,  :a466110, :medium, 40],
    [540,  :a466121, :medium, 40],
    [541,  :a466129, :medium, 40],
    [542,  :a466200, :medium, 40],
    [543,  :a466310, :medium, 40],
    [544,  :a466320, :medium, 40],
    [545,  :a466330, :medium, 40],
    [546,  :a466340, :medium, 40],
    [547,  :a466350, :medium, 40],
    [548,  :a466360, :medium, 40],
    [549,  :a466370, :medium, 40],
    [550,  :a466391, :high,   60],
    [551,  :a466399, :high,   60],
    [552,  :a466910, :medium, 40],
    [553,  :a466920, :medium, 40],
    [554,  :a466931, :medium, 40],
    [555,  :a466932, :medium, 40],
    [556,  :a466939, :medium, 40],
    [557,  :a466940, :medium, 40],
    [558,  :a466990, :medium, 40],
    [559,  :a469010, :medium, 40],
    [560,  :a469090, :medium, 40],
    [561,  :a471110, :medium, 40],
    [562,  :a471120, :medium, 40],
    [563,  :a471130, :medium, 40],
    [564,  :a471190, :medium, 40],
    [565,  :a471900, :medium, 40],
    [566,  :a472111, :medium, 40],
    [567,  :a472112, :medium, 40],
    [568,  :a472120, :medium, 40],
    [569,  :a472130, :medium, 40],
    [570,  :a472140, :medium, 40],
    [571,  :a472150, :medium, 40],
    [572,  :a472160, :medium, 40],
    [573,  :a472171, :medium, 40],
    [574,  :a472172, :medium, 40],
    [575,  :a472190, :medium, 40],
    [576,  :a472200, :medium, 40],
    [577,  :a472300, :medium, 40],
    [578,  :a473000, :medium, 40],
    [579,  :a474010, :medium, 40],
    [580,  :a474020, :medium, 40],
    [581,  :a475110, :medium, 40],
    [582,  :a475120, :medium, 40],
    [583,  :a475190, :medium, 40],
    [584,  :a475210, :medium, 40],
    [585,  :a475220, :medium, 40],
    [586,  :a475230, :medium, 40],
    [587,  :a475240, :medium, 40],
    [588,  :a475250, :medium, 40],
    [589,  :a475260, :medium, 40],
    [590,  :a475270, :medium, 40],
    [591,  :a475290, :high,   60],
    [592,  :a475300, :medium, 40],
    [593,  :a475410, :medium, 40],
    [594,  :a475420, :medium, 40],
    [595,  :a475430, :medium, 40],
    [596,  :a475440, :medium, 40],
    [597,  :a475490, :medium, 40],
    [598,  :a476110, :medium, 40],
    [599,  :a476120, :medium, 40],
    [600,  :a476130, :medium, 40],
    [601,  :a476310, :medium, 40],
    [602,  :a476320, :medium, 40],
    [603,  :a476400, :medium, 40],
    [604,  :a477110, :medium, 40],
    [605,  :a477120, :medium, 40],
    [606,  :a477130, :medium, 40],
    [607,  :a477140, :medium, 40],
    [608,  :a477150, :medium, 40],
    [609,  :a477190, :medium, 40],
    [610,  :a477210, :medium, 40],
    [611,  :a477220, :medium, 40],
    [612,  :a477230, :medium, 40],
    [613,  :a477290, :medium, 40],
    [614,  :a477310, :medium, 40],
    [615,  :a477320, :medium, 40],
    [616,  :a477330, :medium, 40],
    [617,  :a477410, :medium, 40],
    [618,  :a477420, :medium, 40],
    [619,  :a477430, :medium, 40],
    [620,  :a477440, :medium, 40],
    [621,  :a477450, :medium, 40],
    [622,  :a477460, :medium, 40],
    [623,  :a477470, :medium, 40],
    [624,  :a477480, :medium, 40],
    [625,  :a477490, :medium, 40],
    [626,  :a477810, :medium, 40],
    [627,  :a477820, :medium, 40],
    [628,  :a477830, :medium, 40],
    [629,  :a477840, :medium, 40],
    [630,  :a477890, :medium, 40],
    [631,  :a478010, :medium, 40],
    [632,  :a478090, :medium, 40],
    [633,  :a479101, :medium, 40],
    [634,  :a479109, :medium, 40],
    [635,  :a479900, :medium, 40],
    [636,  :a491110, :medium, 40],
    [637,  :a491120, :medium, 40],
    [638,  :a491200, :medium, 40],
    [639,  :a492110, :medium, 40],
    [640,  :a492120, :medium, 40],
    [641,  :a492130, :medium, 40],
    [642,  :a492140, :medium, 40],
    [643,  :a492150, :medium, 40],
    [644,  :a492160, :high,   60],
    [645,  :a492170, :high,   60],
    [646,  :a492180, :high,   60],
    [647,  :a492190, :high,   60],
    [648,  :a492210, :high,   60],
    [649,  :a492221, :high,   60],
    [650,  :a492229, :high,   60],
    [651,  :a492230, :high,   60],
    [652,  :a492240, :high,   60],
    [653,  :a492250, :high,   60],
    [654,  :a492280, :high,   60],
    [655,  :a492290, :high,   60],
    [656,  :a493110, :medium, 40],
    [657,  :a493120, :medium, 40],
    [658,  :a493200, :medium, 40],
    [659,  :a501100, :medium, 40],
    [660,  :a501200, :medium, 40],
    [661,  :a502101, :medium, 40],
    [662,  :a502200, :medium, 40],
    [663,  :a511000, :medium, 40],
    [664,  :a512000, :medium, 40],
    [665,  :a521010, :medium, 40],
    [666,  :a521020, :medium, 40],
    [667,  :a521030, :medium, 40],
    [668,  :a522010, :medium, 40],
    [669,  :a522020, :medium, 40],
    [670,  :a522091, :medium, 40],
    [671,  :a522092, :medium, 40],
    [672,  :a522099, :medium, 40],
    [673,  :a523011, :medium, 40],
    [674,  :a523019, :medium, 40],
    [675,  :a523020, :medium, 40],
    [676,  :a523031, :high,   60],
    [677,  :a523032, :high,   60],
    [678,  :a523039, :medium, 40],
    [679,  :a523090, :high,   60],
    [680,  :a524110, :medium, 40],
    [681,  :a524120, :high,   60],
    [682,  :a524130, :low,    20],
    [683,  :a524190, :low,    20],
    [684,  :a524210, :low,    20],
    [685,  :a524220, :low,    20],
    [686,  :a524230, :low,    20],
    [687,  :a524290, :low,    20],
    [688,  :a524310, :low,    20],
    [689,  :a524320, :low,    20],
    [690,  :a524330, :low,    20],
    [691,  :a524390, :low,    20],
    [692,  :a530010, :low,    20],
    [693,  :a530090, :low,    20],
    [694,  :a551010, :medium, 40],
    [695,  :a551021, :medium, 40],
    [696,  :a551022, :medium, 40],
    [697,  :a551023, :medium, 40],
    [698,  :a551090, :medium, 40],
    [699,  :a552000, :medium, 40],
    [700,  :a561011, :low,    20],
    [701,  :a561012, :low,    20],
    [702,  :a561013, :low,    20],
    [703,  :a561014, :low,    20],
    [704,  :a561019, :low,    20],
    [705,  :a561020, :low,    20],
    [706,  :a561030, :low,    20],
    [707,  :a561040, :low,    20],
    [708,  :a562010, :low,    20],
    [709,  :a562091, :low,    20],
    [710,  :a562099, :low,    20],
    [711,  :a581100, :low,    20],
    [712,  :a581200, :low,    20],
    [713,  :a581300, :low,    20],
    [714,  :a581900, :low,    20],
    [715,  :a591110, :low,    20],
    [716,  :a591120, :low,    20],
    [717,  :a591200, :low,    20],
    [718,  :a591300, :low,    20],
    [719,  :a592000, :low,    20],
    [720,  :a601000, :low,    20],
    [721,  :a602100, :low,    20],
    [722,  :a602200, :low,    20],
    [723,  :a602310, :low,    20],
    [724,  :a602320, :low,    20],
    [725,  :a602900, :low,    20],
    [726,  :a611010, :low,    20],
    [727,  :a611090, :low,    20],
    [728,  :a612000, :low,    20],
    [729,  :a613000, :low,    20],
    [730,  :a614010, :low,    20],
    [731,  :a614090, :low,    20],
    [732,  :a619000, :low,    20],
    [733,  :a620100, :low,    20],
    [734,  :a620200, :low,    20],
    [735,  :a620300, :low,    20],
    [736,  :a620900, :low,    20],
    [737,  :a631110, :low,    20],
    [738,  :a631120, :low,    20],
    [739,  :a631190, :low,    20],
    [740,  :a631200, :low,    20],
    [741,  :a639100, :low,    20],
    [742,  :a639900, :low,    20],
    [743,  :a641100, :medium, 40],
    [744,  :a641910, :medium, 40],
    [745,  :a641920, :medium, 40],
    [746,  :a641930, :medium, 40],
    [747,  :a641941, :medium, 40],
    [748,  :a641942, :medium, 40],
    [749,  :a641943, :medium, 40],
    [750,  :a642000, :medium, 40],
    [751,  :a643001, :medium, 40],
    [752,  :a643009, :medium, 40],
    [753,  :a649100, :medium, 40],
    [754,  :a649210, :medium, 40],
    [755,  :a649220, :medium, 40],
    [756,  :a649290, :medium, 40],
    [757,  :a649910, :medium, 40],
    [758,  :a649991, :medium, 40],
    [759,  :a649999, :medium, 40],
    [760,  :a651110, :low,    20],
    [761,  :a651120, :medium, 40],
    [762,  :a651130, :medium, 40],
    [763,  :a651210, :medium, 40],
    [764,  :a651220, :medium, 40],
    [765,  :a651310, :medium, 40],
    [766,  :a651320, :medium, 40],
    [767,  :a652000, :medium, 40],
    [768,  :a653000, :medium, 40],
    [769,  :a661111, :medium, 40],
    [770,  :a661121, :medium, 40],
    [771,  :a661131, :medium, 40],
    [772,  :a661910, :medium, 40],
    [773,  :a661920, :medium, 40],
    [774,  :a661930, :medium, 40],
    [775,  :a661991, :medium, 40],
    [776,  :a661992, :medium, 40],
    [777,  :a661999, :medium, 40],
    [778,  :a662010, :medium, 40],
    [779,  :a662020, :medium, 40],
    [780,  :a662090, :medium, 40],
    [781,  :a663000, :medium, 40],
    [782,  :a681010, :medium, 40],
    [783,  :a681020, :medium, 40],
    [784,  :a681098, :medium, 40],
    [785,  :a681099, :medium, 40],
    [786,  :a682010, :medium, 40],
    [787,  :a682091, :medium, 40],
    [788,  :a682099, :medium, 40],
    [789,  :a691001, :low,    20],
    [790,  :a691002, :low,    20],
    [791,  :a692000, :low,    20],
    [792,  :a702010, :low,    20],
    [793,  :a702091, :low,    20],
    [794,  :a702092, :low,    20],
    [795,  :a702099, :low,    20],
    [796,  :a711001, :high,   60],
    [797,  :a711002, :low,    20],
    [798,  :a711003, :low,    20],
    [799,  :a711009, :low,    20],
    [800,  :a712000, :low,    20],
    [801,  :a721010, :low,    20],
    [802,  :a721020, :low,    20],
    [803,  :a721030, :low,    20],
    [804,  :a721090, :low,    20],
    [805,  :a722010, :low,    20],
    [806,  :a722020, :low,    20],
    [807,  :a731001, :low,    20],
    [808,  :a731009, :low,    20],
    [809,  :a732000, :low,    20],
    [810,  :a741000, :low,    20],
    [811,  :a742000, :low,    20],
    [812,  :a749001, :low,    20],
    [813,  :a749002, :low,    20],
    [814,  :a749003, :low,    20],
    [815,  :a749009, :low,    20],
    [816,  :a750000, :low,    20],
    [817,  :a771110, :low,    20],
    [818,  :a771190, :low,    20],
    [819,  :a771210, :low,    20],
    [820,  :a771220, :low,    20],
    [821,  :a771290, :low,    20],
    [822,  :a772010, :low,    20],
    [823,  :a772091, :low,    20],
    [824,  :a772099, :low,    20],
    [825,  :a773010, :low,    20],
    [826,  :a773020, :medium, 40],
    [827,  :a773030, :high,   60],
    [828,  :a773040, :low,    20],
    [829,  :a773090, :low,    20],
    [830,  :a774000, :low,    20],
    [831,  :a780000, :low,    20],
    [832,  :a791100, :low,    20],
    [833,  :a791200, :low,    20],
    [834,  :a791901, :low,    20],
    [835,  :a791909, :low,    20],
    [836,  :a801010, :low,    20],
    [837,  :a801020, :low,    20],
    [838,  :a801090, :low,    20],
    [839,  :a811000, :low,    20],
    [840,  :a812010, :low,    20],
    [841,  :a812020, :low,    20],
    [842,  :a812090, :low,    20],
    [843,  :a813000, :low,    20],
    [844,  :a821100, :low,    20],
    [845,  :a821900, :low,    20],
    [846,  :a822000, :low,    20],
    [847,  :a823000, :low,    20],
    [848,  :a829100, :medium, 40],
    [849,  :a829200, :low,    20],
    [850,  :a829900, :low,    20],
    [851,  :a841100, :medium, 40],
    [852,  :a841200, :medium, 40],
    [853,  :a841300, :medium, 40],
    [854,  :a841900, :medium, 40],
    [855,  :a842100, :low,    20],
    [856,  :a842200, :low,    20],
    [857,  :a842300, :low,    20],
    [858,  :a842400, :low,    20],
    [859,  :a842500, :low,    20],
    [860,  :a843000, :low,    20],
    [861,  :a851010, :low,    20],
    [862,  :a851020, :low,    20],
    [863,  :a852100, :low,    20],
    [864,  :a852200, :low,    20],
    [865,  :a853100, :low,    20],
    [866,  :a853201, :low,    20],
    [867,  :a853300, :low,    20],
    [868,  :a854910, :low,    20],
    [869,  :a854920, :low,    20],
    [870,  :a854930, :low,    20],
    [871,  :a854940, :low,    20],
    [872,  :a854950, :low,    20],
    [873,  :a854960, :low,    20],
    [874,  :a854990, :low,    20],
    [875,  :a855000, :low,    20],
    [876,  :a861010, :low,    20],
    [877,  :a861020, :low,    20],
    [878,  :a862110, :low,    20],
    [879,  :a862120, :low,    20],
    [880,  :a862130, :low,    20],
    [881,  :a862200, :low,    20],
    [882,  :a863110, :low,    20],
    [883,  :a863120, :low,    20],
    [884,  :a863190, :low,    20],
    [885,  :a863200, :low,    20],
    [886,  :a863300, :low,    20],
    [887,  :a864000, :low,    20],
    [888,  :a869010, :low,    20],
    [889,  :a869090, :low,    20],
    [890,  :a870100, :low,    20],
    [891,  :a870210, :low,    20],
    [892,  :a870220, :low,    20],
    [893,  :a870910, :low,    20],
    [894,  :a870920, :low,    20],
    [895,  :a870990, :low,    20],
    [896,  :a880000, :low,    20],
    [897,  :a900011, :low,    20],
    [898,  :a900021, :low,    20],
    [899,  :a900030, :low,    20],
    [900,  :a900040, :low,    20],
    [901,  :a900091, :low,    20],
    [902,  :a910100, :low,    20],
    [903,  :a910200, :low,    20],
    [904,  :a910300, :low,    20],
    [905,  :a910900, :low,    20],
    [906,  :a920001, :high,   60],
    [907,  :a920009, :high,   60],
    [908,  :a931010, :low,    20],
    [909,  :a931020, :low,    20],
    [910,  :a931030, :low,    20],
    [911,  :a931041, :low,    20],
    [912,  :a931042, :low,    20],
    [913,  :a931050, :low,    20],
    [914,  :a931090, :low,    20],
    [915,  :a939010, :low,    20],
    [916,  :a939020, :low,    20],
    [917,  :a939030, :low,    20],
    [918,  :a939090, :low,    20],
    [919,  :a941100, :low,    20],
    [920,  :a941200, :low,    20],
    [921,  :a942000, :high,   60],
    [922,  :a949100, :medium, 40],
    [923,  :a949200, :high,   60],
    [924,  :a949910, :high,   60],
    [925,  :a949920, :low,    20],
    [926,  :a949930, :high,   60],
    [927,  :a949990, :medium, 40],
    [928,  :a951100, :low,    20],
    [929,  :a951200, :low,    20],
    [930,  :a952200, :low,    20],
    [931,  :a952300, :low,    20],
    [932,  :a952910, :low,    20],
    [933,  :a952920, :low,    20],
    [934,  :a952990, :low,    20],
    [935,  :a960101, :low,    20],
    [936,  :a960102, :low,    20],
    [937,  :a960201, :low,    20],
    [938,  :a960202, :low,    20],
    [939,  :a960300, :low,    20],
    [940,  :a960910, :low,    20],
    [941,  :a960990, :medium, 40],
    [942,  :a970000, :medium, 40],
    [943,  :a990000, :medium, 40],
    [944,  :a952100, :medium, 40],
    [945,  :a476200, :medium, 40],
    [946,  :a464910, :medium, 40],
    [947,  :a461091, :medium, 40],
    [948,  :a431220, :high,   60],
    [949,  :a331301, :medium, 40],
    [950,  :a14221,  :medium, 40],
    [951,  :a7,      :low,    20],
    [952,  :a8,      :low,    20],
    [953,  :a9,      :low,    20],
    [954,  :a10,     :low,    20],
    [955,  :a11,     :low,    20],
    [956,  :a12,     :medium, 40],
    [957,  :a13,     :low,    20],
  ]
end
 