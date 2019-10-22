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
    [12, :disable_person],
    [13, :update_person_regularity],
    [14, :download_attachments],
    [15, :person_new],
    [16, :person_enabled],
    [17, :person_disabled],
    [18, :person_rejected]
  ]

  def name
    code
  end
end
