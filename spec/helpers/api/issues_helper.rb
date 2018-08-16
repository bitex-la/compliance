require 'spec_helper'
class Api::IssuesHelper
  include RSpec::Rails::FixtureFileUploadSupport

  def self.issue_without_person
    {
      data: {
        type: "issue",
        attributes: {
        },
        relationships: {
        }
      },
      included: [
      ]
    }
  end

  def self.issue_with_current_person(person_id)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          person: {
            data: {
              id: person_id,
              type: "people"
            }
          }
        }
      },
      included: [
      ]
    }
  end

  def self.issue_with_an_observation(person_id, reason, note)
    {
      data: {
        id: '@1',
        type: "issues",
        attributes: {

        },
        relationships: {
          person: {
            data: {
              id: person_id,
              type: "people"
            }
          },
          observations:{data:[{id: "@1", type:"observations"}]},
        }
      },
      included: [
         observation_for('@1', reason, note)
      ]
    }
  end

  def self.basic_issue
    {
      data: {
        type: "issue",
        attributes: {

        },
        relationships: {
          people: {
            data: {
              id: "@1",
              type: "people"
            }
          }
        }
      },
      included: [
        {
          type: "people",
          id: "@1"
        }
      ]
    }
  end

  def self.invalid_basic_issue
    {
      data: {
        type: "issue",
        attributes: {
        },
        relationships: {
          person: {
            data: {
              id: "",
              type: "person"
            }
          }
        }
      },
      included: [
      ]
    }
  end

  def self.issue_with_affinity_seed(related_person, attachment_type)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          affinity_seeds: {
            data: [{ id: "@1", type: "affinity_seeds" }]
          }
        }
      },
      included: [
        {
          type: "affinity_seeds",
          id: "@1",
          attributes: {
            affinity_kind_code: "spouse"
          },
          relationships: {
            issue: {
              data: {id: "@1", type: 'issues'}
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
        attachment_for(attachment_type, '@1'),
      ]
    }
  end


  def self.issue_with_domicile_seed(attachment_type)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          domicile_seeds: {
            data: [{ id: "@1", type: "domicile_seeds" }]
          }
        }
      },
      included: [
        {
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
              data: {id: "@1", type: 'issues'}
            },
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.issue_with_phone_seed(attachment_type)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          phone_seeds: {
            data: [{ id: "@1", type: "phone_seeds" }]
          }
        }
      },
      included: [
        {
          type: "phone_seeds",
          id: "@1",
          attributes: {
            number: "+54911282256470",
            phone_kind_code: "main",
            country: "AR",
            has_whatsapp: true,
            has_telegram: false,
            note: "only on office hours",
          },
          relationships: {
            issue: {
              data: {id: "@1", type: 'issues'}
            },
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.issue_with_email_seed(attachment_type)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          email_seeds: {
            data: [{ id: "@1", type: "email_seeds" }]
          }
        }
      },
      included: [
        {
          type: "email_seeds",
          id: "@1",
          attributes: {
            address: "joe.doe@test.com",
            email_kind_code: "personal",
          },
          relationships: {
            issue: {
              data: {id: "@1", type: 'issues'}
            },
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.issue_with_argentina_invoicing_seed(attachment_type)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          argentina_invoicing_detail_seed: {
            data: { id: "@1", type: "argentina_invoicing_detail_seeds" }
          }
        }
      },
      included: [
        {
          type: "argentina_invoicing_detail_seeds",
          id: "@1",
          attributes: {
            vat_status_code: "monotributo",
            tax_id: "2022443870",
            tax_id_kind_code: "cuit",
            receipt_kind_code: "a",
            name: "Jorge Galvan",
            country: "AR",
            address: "Bucarelli 2675"
          },
          relationships: {
            issue: {
              data: {id: "@1", type: 'issues'}
            },
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.issue_with_chile_invoicing_seed(attachment_type)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          chile_invoicing_detail_seed: {
            data: { id: "@1", type: "chile_invoicing_detail_seeds" }
          }
        }
      },
      included: [
        {
          type: "chile_invoicing_detail_seeds",
          id: "@1",
          attributes: {
            vat_status_code: "monotributo",
            tax_id: "2022443870",
            giro: 'sfsdffd',
            ciudad: 'Santiago',
            comuna: 'Condes'
          },
          relationships: {
            issue: {
              data: {id: "@1", type: 'issues'}
            },
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1'),
      ]
    }
  end

  def self.issue_with_identification_seed(attachment_type)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          identification_seeds: {
            data: [{ id: "@1", type: "identification_seeds" }]
          }
        }
      },
      included:[
        {
          type: "identification_seeds",
          id: "@1",
          attributes: {
            identification_kind_code: "national_id",
            number: "AQ322812",
            issuer: "CO"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.issue_with_risk_score_seed(attachment_type)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          risk_score_seeds: {
            data: [{ id: "@1", type: "risk_score_seeds" }]
          }
        }
      },
      included:[
        {
          type: "risk_score_seeds",
          id: "@1",
          attributes: {
            score: "green",
            provider: "chainalysis",
            extra_info: '{"hello": "world"}',
            external_link: "https://test.chainalysis.com/docs/risk-api/#/"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.issue_with_natural_docket_seed(attachment_type)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          natural_docket_seed: {
            data:
            {
              id: "@1",
              type: "natural_docket_seeds"
            }
          }
        }
      },
      included:[
        {
          type: "natural_docket_seeds",
          id: "@1",
          attributes: {
            first_name: "joe",
            last_name: "doe",
            birth_date: "2018-01-01",
            nationality: "AR",
            gender_code: "male",
            marital_status_code: "single"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.issue_with_legal_entity_docket_seed(attachment_type)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          legal_entity_docket_seed: {
            data:
            {
              id: "@1",
              type: "legal_entity_docket_seeds"
            }
          }
        }
      },
      included:[
        {
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
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.issue_with_allowance_seed(attachment_type)
    {
      data: {
        type: "issues",
        attributes: {
        },
        relationships: {
          allowance_seeds: {
            data:
             [{
              id: "@1",
              type: "allowance_seeds"
             }]
          }
        }
      },
      included:[
        {
          type: "allowance_seeds",
          id: "@1",
          attributes: {
            weight: 10,
            amount: 1000,
            kind_code: "usd"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachments"
              }]
            }
          }
        },
        attachment_for(attachment_type, '@1')
      ]
    }
  end

  def self.natural_docket_seed(attachment_type)
    [{
      type: "natural_docket_seeds",
      id: "@1",
      attributes: {
        first_name: "joe",
        last_name: "jones",
        birth_date: "2018-01-01",
        nationality: "AR",
        gender_code: "male",
        marital_status_code: "single"
      },
      relationships: {
        attachments: {
          data: [{
            id: "@2",
            type: "attachments"
          }]
        }
      }
    },
    attachment_for(attachment_type, '@2')]
  end

  def self.observation_for(issue, reason, note, scope = 'admin')
    {
      id: "@1",
      type: "observations",
      relationships: {
        issue: {data: {id: issue, type: "issues"}},
        observation_reason: {data: {id: reason.id.to_s, type: "observation_reasons"}}
      },
      attributes: { note: note, scope: scope }
    }
  end

  def self.mime_for(ext)
    case ext
      when :png, :jpg, :gif then "image/#{ext}"
      when :pdf, :zip then "application/#{ext}"
      when :rar then "application/x-rar-compressed"
      else raise "No fixture for #{ext} files"
    end
  end

  def self.bytes_for(ext)
    fixtures = RSpec.configuration.file_fixture_path
    path = Pathname.new(File.join(fixtures, "simple.#{ext}"))
    Base64.encode64(path.read).delete!("\n")
  end

  def self.attachment_for(ext, id)
    {
      type: "attachments",
      id: id,
      attributes: {
        document: "data:#{mime_for(ext)};base64,#{bytes_for(ext)}",
        document_file_name: "file.#{ext}",
        document_content_type: mime_for(ext)
      }
    }
  end

  def self.seed_attachment_payload(ext, id, person_id, seed_id, type)
    {
      data: {
        type: "attachments",
        id: id,
        attributes: {
          document: "data:#{mime_for(ext)};base64,#{bytes_for(ext)}",
          document_file_name: "file.#{ext}",
          document_content_type: mime_for(ext)
        },
        relationships: {
          person: {
            data: {
              id: person_id,
              type: "people"
            }
          },
          attached_to_fruit: {
            data: nil
          },
          attached_to_seed: {
            data: {
              id: seed_id,
              type: type
            }
          }
        }
      }
    }
  end
end
