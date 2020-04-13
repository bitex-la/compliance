class Api::PhoneSeedsController < Api::EntityController
  def resource_class
    PhoneSeed
  end

  protected

  def related_person
    resource.issue.person_id
  end

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :phones, :phone_seeds],
      issues: [],
      phones: [],
      phone_seeds: [
        :number,
        :phone_kind_code,
        :country,
        :has_whatsapp,
        :has_telegram,
        :note,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at,
        :archived_at
      ]
  end
end
