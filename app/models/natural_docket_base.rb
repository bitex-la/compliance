class NaturalDocketBase < ApplicationRecord
  strip_attributes

  before_validation :sanitize_birth_date

  self.abstract_class = true
  ransackable_static_belongs_to :marital_status,
    class_name: 'MaritalStatusKind', required: false
  ransackable_static_belongs_to :gender, class_name: 'GenderKind',
    required: false

  validates :first_name, :last_name, :job_title, :nationality,
    length: { maximum: 255 }

  def name_body
    [first_name, last_name].join(' ')
  end

  private

  def sanitize_birth_date
    unless !self.birth_date
      self.birth_date = StripAttributes
        .strip(self.birth_date.strftime('%Y-%m-%d'), regex: /^-+|-+$/)
    end
  end
end
