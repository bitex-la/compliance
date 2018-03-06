FactoryBot.define_persons_item_and_seed(:natural_docket,
  full_natural_docket: proc {
    first_name     'Joe'
    last_name      'Doe'
    birth_date     '2018-02-26'
    nationality    'Argentina'
    gender         'Male'
    marital_status 'Single'
    transient{ add_all_attachments true }
  }
)
