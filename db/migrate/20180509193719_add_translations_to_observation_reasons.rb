class AddTranslationsToObservationReasons < ActiveRecord::Migration[5.1]
  def change
    add_column :observation_reasons, :subject_es, :string
    add_column :observation_reasons, :body_es, :text
    add_column :observation_reasons, :subject_pt, :string
    add_column :observation_reasons, :body_pt, :text
    rename_column :observation_reasons, :subject, :subject_en
    rename_column :observation_reasons, :body, :body_en
  end
end
