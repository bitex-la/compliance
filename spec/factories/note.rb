FactoryBot.define_persons_item_and_seed(:note,
  full_note: proc {
    title { 'my nickname' }
    body { 'Please call me by my nickname: Mr. Bond' }
    transient{ add_all_attachments { true } }
  }
)
