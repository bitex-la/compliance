class Event::IssueLogger

  def self.call(issue, user, verb)
    EventLog.create!(
      entity: issue,
      raw_data: IssueSerializer.new(
        issue,
        {include: Issue.included_for_issue}
      ).serialized_json,
      admin_user: user,
      verb: verb
    )
  end

  def self.included_for_issue
    [
      :person,
      :'person.identifications',
      :'person.domiciles',
      :'person.natural_dockets',
      :'person.legal_entity_dockets',
      :'person.argentina_invoicing_details',
      :'person.chile_invoicing_details',
      :'person.phones',
      :'person.emails',
      :'person.notes',
      :'person.affinities',
      :'person.allowances',
      :natural_docket_seed,
      :'natural_docket_seed.attachments',
      :legal_entity_docket_seed,
      :'legal_entity_docket_seed.attachments',
      :argentina_invoicing_detail_seed,
      :'argentina_invoicing_detail_seed.atachments',
      :chile_invoicing_detail_seed,
      :'chile_invoicing_detail_seed.attachments',
      :allowance_seeds,
      :'allowance_seeds.attachments',
      :phone_seeds,
      :'phone_seeds.attachments',
      :email_seeds,
      :'email_seeds.attachments',
      :note_seeds,
      :'note_seeds.attachments',
      :domicile_seeds,
      :'domicile_seeds.attachments',
      :affinity_seeds,
      :'affinity_seeds.attachments',
      :identification_seeds,
      :'identifications_seeds.attachments',
      :observations,
      :'observations.observation_reason'
    ]
  end
end
