FactoryBot.define_persons_item_and_seed(:note,
  full_note: proc {
    title  'my nickname'
    body   'Please call me by my nickname: Mr. Bond' 
    transient{ add_all_attachments true }
  }
)

FactoryBot.define do 
  factory :strange_note_seed, class: NoteSeed do 
    title  {'my niçknamé'}
    body   {'Please call me by my nickname: Mr. 微信图片' * 1000} 
  end
end
