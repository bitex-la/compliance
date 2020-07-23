class AdminRole
  include StaticModels::Model

  static_models_dense [
    [:id, :code,                   :name,         :root_page],
    [1,   :admin,                  'admin',       'dashboards'],
    [2,   :marketing,              'marketing',   'people'],
    [3,   :compliance,             'compliance',  'dashboards'],
    [4,   :operations,             'operations',  'dashboards'],
    [5,   :commercial,             'commercial',  'dashboards'],
    [6,   :security,               'security',    'admin_users'],
    [7,   :restricted,             'restricted',  'people']
  ]
end
