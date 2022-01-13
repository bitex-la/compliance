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

  after_validation :clean_paperclip_errors

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

  validates_attachment_content_type :document,
                                    content_type: %w[
                                      image/bmp
                                      image/jpeg
                                      image/jpg
                                      image/gif
                                      image/png
                                      application/pdf
                                      application/doc
                                      application/msword
                                      application/vnd.openxmlformats-officedocument.wordprocessingml.document
                                      application/vnd.ms-excel
                                      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
                                    ],
                                    message: lambda {|attachment, metadata| "File #{attachment.document_file_name} has an invalid content type." }

  validates_attachment_file_name :document,
                                 matches: [
                                   /bmp|BMP\z/,
                                   /png|PNG\z/,
                                   /jpg|JPG\z/,
                                   /jpeg|JPEG\z/,
                                   /pdf|PDF\z/,
                                   /gif|GIF\z/,
                                   /doc|DOC\z/,
                                   /docx|DOCX\z/,
                                   /xls|XLS\z/,
                                   /xlsx|XLSX\z/
                                 ],
                                 message: lambda {|attachment, metadata| "File #{attachment.document_file_name} contains an invalid file name." }

  validates_attachment_size :document,
                            less_than: 10.megabytes,
                            message: lambda {|attachment, metadata| "File #{attachment.document_file_name} size must be lower than 10MB." }

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

  def clean_paperclip_errors
    errors.delete(:document)
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
