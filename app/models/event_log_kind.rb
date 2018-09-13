class EventLogKind
  include StaticModels::Model

  static_models_sparse [
    [1,  :create_entity],
    [2,  :update_entity],
    [3,  :delete_entity],
    [4,  :harvest_seed],
    [5,  :observe_issue],
    [6,  :answer_issue],
    [7,  :dismiss_issue],
    [8,  :reject_issue],
    [9,  :approve_issue],
    [10, :abandon_issue],
    [11, :enable_person],
    [12, :disable_person]
  ]

  def name
    code
  end
end