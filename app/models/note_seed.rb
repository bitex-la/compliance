class NoteSeed < NoteBase
  include Garden::Seed

  def self.note_seeds_condition
    where('note_seeds.created_at > ?', DateTime.parse(Settings.fiat_only.start_date)) if AdminUser.current_admin_user&.fiat_only?
  end
end
