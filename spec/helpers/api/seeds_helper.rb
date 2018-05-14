require 'spec_helper'
class Api::SeedsHelper
  include RSpec::Rails::FixtureFileUploadSupport

  def self.note_seed(issue, attachment_type)
    {
      data: {
        type: "note_seeds",
        id: "@1",
        attributes: {
          title: 'My nickname',
          body: 'Call me mr. robot'
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included:[
        Api::IssuesHelper.attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.allowance_seed(issue, attachment_type)
    {
      data: {
        type: "allowance_seeds",
        id: "@1",
        attributes: {
          weight: 10,
          amount: 1000,
          kind: "USD"
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included:[
        Api::IssuesHelper.attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.identification_seed(issue, attachment_type)
    {
      data: {
        type: "identification_seeds",
        id: "@1",
        attributes: {
          identification_kind: "national_id",
          number: "AQ322812",
          issuer: "CO"
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included:[
        Api::IssuesHelper.attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.email_seed(issue, attachment_type)
    mime, bytes =
    {
      data: {
        type: "email_seeds",
        id: "@1",
        attributes: {
          address: "joe.doe@test.com",
          email_kind: "personal",
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included: [
        Api::IssuesHelper.attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.domicile_seed(issue, attachment_type)
    mime, bytes =
    {
      data: {
        type: "domicile_seeds",
        id: "@1",
        attributes: {
          country: "AR",
          state: "buenos aires",
          city: "CABA",
          street_address: "cullen",
          street_number: "2345",
          postal_code: "1234",
          floor: "4",
          apartment: "a"
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included: [
        Api::IssuesHelper.attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.affinity_seed(related_issue, related_person, attachment_type)
    mime, bytes =
    {
      data: {
        type: "affinity_seeds",
        id: "@1",
        attributes: {
          affinity_kind: "spouse"
        },
        relationships: {
          issue: {
            data: {id: related_issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          },
          related_person: {
            data: {id: related_person.id, type: "people"}
          }
        }
      },
      included: [
        Api::IssuesHelper.attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.phone_seed(issue, attachment_type)
    mime, bytes =
    {
      data: {
        type: "phone_seeds",
        id: "@1",
        attributes: {
          number: "+54911282256470",
          phone_kind: "main",
          country: "AR",
          has_whatsapp: true,
          has_telegram: false,
          note: "only on office hours",
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included: [
        Api::IssuesHelper.attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.natural_docket_seed(issue, attachment_type)
    {
      data: {
        type: "natural_docket_seeds",
        id: "@1",
        attributes: {
          first_name: "joe",
          last_name: "doe",
          birth_date: "2018-01-01",
          nationality: "AR",
          gender: "male",
          marital_status: "single"
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included:[
        Api::IssuesHelper.attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.legal_entity_docket_seed(issue, attachment_type)
    {
      data: {
        type: "legal_entity_docket_seeds",
        id: "@1",
        attributes: {
          industry: "software",
          business_description: "software factory",
          country: "AR",
          commercial_name: "my soft",
          legal_name: "mySoft SRL"
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included:[
        Api::IssuesHelper.attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.argentina_invoicing_detail_seed(issue, attachment_type)
    mime, bytes =
    {
      data: {
        type: "argentina_invoicing_detail_seeds",
        id: "@1",
        attributes: {
          vat_status: "monotributo",
          tax_id: "2022443870",
          tax_id_kind: "cuit",
          receipt_kind: "a",
          name: "Jorge Galvan",
          country: "AR",
          address: "Bucarelli 2675"
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included: [
        Api::IssuesHelper.attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.chile_invoicing_detail_seed(issue, attachment_type)
    mime, bytes =
    {
      data: {
        type: "chile_invoicing_detail_seeds",
        id: "@1",
        attributes: {
          vat_status: "monotributo",
          tax_id: "2022443870",
          giro: 'sfsdffd',
          ciudad: 'Santiago',
          comuna: 'Condes'
        },
        relationships: {
          issue: {
            data: {id: issue.id, type: 'issues'}
          },
          attachments: {
            data: [{
              id: "@1",
              type: "attachments"
            }]
          }
        }
      },
      included: [
        Api::IssuesHelper.attachment_for(attachment_type, '@1'),
      ]
    }
  end
end
