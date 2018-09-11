require 'spec_helper'
class Api::IssuesHelper
  include RSpec::Rails::FixtureFileUploadSupport

  def self.base_resource(type, id)
    base = { type: type, attributes: {}, relationships: {} }
    base[:id] = id if id
    base
  end

  def self.link(type, id)
    { data: { type: type, id: id } }
  end

  def self.issue_for(issue_id, person_id)
    base = base_resource("issues", issue_id)
    base[:relationships][:person] = link('people', person_id) if person_id
    base 
  end

  def self.observation_for(observation_id, issue_id, note, scope, reason_id)
    base = base_resource("observations", observation_id)
    base[:relationships][:issue] = link('issues', issue_id) if issue_id
    if reason_id
      base[:relationships][:observation_reason] =
        link('observation_reasons', reason_id)
    end
    base[:attributes][:note] = note if note
    base[:attributes][:scope] = scope if scope
    base
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

  def self.issue_with_affinity_seed(person, related_person, attachment_type)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
        attachment_for(attachment_type, '@1', 'affinity_seeds', '@1'),
      ]
    }
  end


  def self.issue_with_domicile_seed(person, attachment_type, accented = false)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          domicile_seeds: {
            data: [{ id: "@1", type: "domicile_seeds" }]
          },
          person: { data: { id: person.id, type: "people" } }
        }
      },
      included: [
        attachment_for(attachment_type, '@1', 'domicile_seeds', '@1', accented),
      ]
    }
  end

  def self.issue_with_phone_seed(person, attachment_type, accented = false)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
        attachment_for(attachment_type, '@1', 'phone_seeds', '@1', accented),
      ]
    }
  end

  def self.issue_with_email_seed(person, attachment_type, accented = false)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
        attachment_for(attachment_type, '@1', 'email_seeds', '@1', accented),
      ]
    }
  end

  def self.issue_with_argentina_invoicing_seed(person, attachment_type, accented = false)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
            full_name: "Jorge Galvan",
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
        attachment_for(attachment_type, '@1', 'argentina_invoicing_detail_seeds', '@1', accented),
      ]
    }
  end

  def self.issue_with_chile_invoicing_seed(person, attachment_type, accented = false)
    mime, bytes =
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: { },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
        attachment_for(attachment_type, '@1', 'chile_invoicing_detail_seeds', '@1', accented),
      ]
    }
  end

  def self.issue_with_identification_seed(person, attachment_type, accented = false)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          identification_seeds: {
            data: [{ id: "@1", type: "identification_seeds" }]
          },
          person: { data: { id: person.id, type: "people" } }
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
        attachment_for(attachment_type, '@1', 'identification_seeds', '@1', accented)
      ]
    }
  end

  def self.issue_with_risk_score_seed(person, attachment_type, accented = false)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
        attachment_for(attachment_type, '@1', 'risk_score_seeds', '@1', accented)
      ]
    }
  end

  def self.issue_with_natural_docket_seed(person, attachment_type, accented = false)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
        attachment_for(attachment_type, '@1', 'natural_docket_seeds', '@1', accented)
      ]
    }
  end

  def self.issue_with_legal_entity_docket_seed(person, attachment_type, accented = false)
    {
      data: {
        type: "issues",
        attributes: {

        },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
        attachment_for(attachment_type, '@1', 'legal_entity_docket_seeds', '@1', accented)
      ]
    }
  end

  def self.issue_with_allowance_seed(person, attachment_type, accented = false)
    {
      data: {
        type: "issues",
        attributes: {
        },
        relationships: {
          person: { data: { id: person.id, type: "people" } },
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
        attachment_for(attachment_type, '@1', 'allowance_seeds', '@1', accented)
      ]
    }
  end

  def self.natural_docket_seed(attachment_type, accented = false)
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
    attachment_for(attachment_type, '@2', 'natural_docket_seeds', '@1', accented)]
  end

  def self.mime_for(ext)
    case ext
      when :png, :jpg, :gif, :JPG, :PNG, :GIF then "image/#{ext.downcase}"
      when :pdf, :zip, :PDF, :ZIP then "application/#{ext.downcase}"
      when :rar, :RAR then "application/x-rar-compressed"
      else raise "No fixture for #{ext.downcase} files"
    end
  end

  def self.bytes_for(ext)
    fixtures = RSpec.configuration.file_fixture_path
    filename = if ext == ext.upcase
      "simple_upper.#{ext}"
    else
      "simple.#{ext}"
    end
  
    path = Pathname.new(File.join(fixtures, filename))
    Base64.encode64(path.read).delete!("\n")
  end

  def self.attachment_for(ext, id, seed_type, seed_id, accented = false)
    filename = if accented
      "áñçfile"
    else
      "file"
    end
    {
      type: "attachments",
      id: id,
      relationships: {
        attached_to_seed: {
          data: {
            id: seed_id,
            type: seed_type
          }
        }
      },
      attributes: {
        document: "data:#{mime_for(ext)};base64,#{bytes_for(ext)}",
        document_file_name: "#{filename}.#{ext}",
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
