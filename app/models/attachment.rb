class Attachment < ApplicationRecord
  belongs_to :person
  belongs_to :attached_to_fruit, polymorphic: true, optional: true
  belongs_to :attached_to_seed, polymorphic: true, optional: true
  has_attached_file :document, optional: true

  before_validation :relate_to_person
  before_validation :classify_type

  validate :attached_to_something
  validates :person, presence: true
  validate :person_cannot_be_removed_once_set

  before_save :classify_type
  after_save{ person.expire_action_cache }

  include PersonScopeable

  def self.attachable_to_fruits
   %w(domicile phone email note
     affinity identification natural_docket
     risk_score legal_entity_docket allowance
     argentina_invoicing_detail chile_invoicing_detail
   )
  end

  def self.attachable_to
    all = []
    self.attachable_to_fruits.each do |a|
      all += [a.pluralize, "#{a}_seeds"]
    end
    all + %w[fund_deposits fund_withdrawals fund_transfers]
  end
 
  validates_attachment :document,
    content_type: {
      content_type: [
        'image/bmp',
        'image/jpeg',
        'image/jpg',
        'image/heic',
        'image/heif',
        'image/gif',
        'image/png',
        'application/pdf',
        'application/zip',
        'application/x-rar-compressed'
    ]}

  validates_attachment_file_name :document, matches: [
    /bmp|BMP\z/,
    /png|PNG\z/,
    /jpg|JPG\z/,
    /jpeg|JPEG\z/,
    /heif|HEIF\z/,
    /heic|HEIC\z/,
    /pdf|PDF\z/,
    /gif|GIF\z/,
    /zip|ZIP\z/,
    /rar|RAR\z/,
  ]

  def attached_to_something
    return unless attached_to.nil?

    errors.add(:base, 'must_be_attached_to_something')
  end

  def person_cannot_be_removed_once_set
    return unless person_id_was.presence && person.nil?
    errors.add(:base, 'cant_unassign_person')
  end

  def document_url
    self.document.expiring_url
  end

  def name
    "##{id}: #{document_file_name} #{document_content_type}"
  end

  def attached_to_seed_gid=(gid)
    self.attached_to_seed = GlobalID::Locator.locate GlobalID.parse(gid)
  end

  def attached_to_seed_gid
    return unless attached_to_seed
    attached_to_seed.to_global_id.to_s
  end

  def attached_to_fruit_gid=(gid)
    self.attached_to_fruit = GlobalID::Locator.locate GlobalID.parse(gid)
  end

  def attached_to_fruit_gid
    return unless attached_to_fruit
    attached_to_fruit.to_global_id.to_s
  end

  def attached_to
    attached_to_fruit || attached_to_seed
  end

  def attached_to_type
    attached_to.class.name
  end

  def issue
    attached_to_seed.try(:issue)
  end

  private

  def relate_to_person
    self.person_id = attached_to&.person&.id
  end

  def classify_type
    # If the attached to type is set via jsonapi, we need to convert it
    # to the corresponding rails type.
    unless self.attached_to_seed_type.nil?
      self.attached_to_seed_type = self.attached_to_seed_type.camelize.singularize
    end 
  end
end
