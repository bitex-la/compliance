FactoryBot.define_persons_item_and_seed(:note,
  full_note: proc {
    title { 'my nickname' }
    body { 'Please call me by my nickname: Mr. Bond' }
    transient { add_all_attachments { true } }
  },
  alt_full_note: proc {
    title { 'oh my god' }
    body { 'A super duper body' }
    transient { add_all_attachments { true } }
  }
)
