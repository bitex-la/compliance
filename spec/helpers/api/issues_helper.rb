require 'spec_helper'
module Api::IssuesHelper
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
        type: "issue",
        attributes: {
          
        },
        relationships: {
          person: {
            data: {
              id: person_id,
              type: "person"
            }
          }
        }
      },
      included: [
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
          person: {
            data: {
              id: "@1",
              type: "person"
            }
          }
        }
      },
      included: [
        {
          type: "person",
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

  def self.issue_with_domicile_seed(attachment, content_type, file_name)
    {
      data: {
        type: "issue",
        attributes: {
          
        },
        relationships: {
          person: {
            data: {
              id: "@1",
              type: "person"
            }
          },
          domicile_seeds: {
            data: [
              {
                id: "@1",
                type: "domicile_seed"
              }
            ],
          }
        }
      },
      included:[
        {
          type: "person",
          id: "@1"
        },
        {
          type: "domicile_seed",
          id: "@1",
          attributes: {
            country: "argentina",
            state: "buenos aires",
            city: "CABA",
            street_address: "cullen",
            street_number: "2345",
            postal_code: "1234",
            floor: "4",
            apartment: "a"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachment"
              }]
            }
          }
        },
        {
          type: "attachment",
          id: "@1",
          attributes: {
            document: "data:#{content_type};base64,#{attachment.delete!("\n")}",
            document_file_name: file_name,
            document_content_type: content_type
          }
        }
      ]
    }
  end

  def self.issue_with_identification_seed(attachment, content_type, file_name)
    {
      data: {
        type: "issue",
        attributes: {
          
        },
        relationships: {
          person: {
            data: {
              id: "@1",
              type: "person"
            }
          },
          identification_seeds: {
            data: [
            {
              id: "@1",
              type: "identification_seed"
            }
            ]
          }
        }
      },
      included:[
        {
          type: "person",
          id: "@1"
        },
        {
          type: "identification_seed",
          id: "@1",
          attributes: {
            kind: "passport",
            number: "AQ322812",
            issuer: "Colombia"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachment"
              }]
            }
          }
        },
        {
          type: "attachment",
          id: "@1",
          attributes: {
            document: "data:#{content_type};base64,#{attachment.delete!("\n")}",
            document_file_name: file_name,
            document_content_type: content_type
          }
        }
      ]
    }
  end

  def self.issue_with_natural_docket_seed(attachment, content_type, file_name)
    {
      data: {
        type: "issue",
        attributes: {
          
        },
        relationships: {
          person: {
            data: {
              id: "@1",
              type: "person"
            }
          },
          natural_docket_seeds: {
            data: [
            {
              id: "@1",
              type: "natural_docket_seed"
            }
            ]
          }
        }
      },
      included:[
        {
          type: "person",
          id: "@1"
        },
        {
          type: "natural_docket_seed",
          id: "@1",
          attributes: {
            first_name: "joe",
            last_name: "doe",
            birth_date: "1985-10-08",
            nationality: "argentina",
            gender: "male",
            marital_status: "single"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachment"
              }]
            }
          }
        },
        {
          type: "attachment",
          id: "@1",
          attributes: {
            document: "data:#{content_type};base64,#{attachment.delete!("\n")}",
            document_file_name: file_name,
            document_content_type: content_type
          }
        }
      ]
    }
  end

  def self.issue_with_legal_entity_docket_seed(attachment, content_type, file_name)
    {
      data: {
        type: "issue",
        attributes: {
          
        },
        relationships: {
          person: {
            data: {
              id: "@1",
              type: "person"
            }
          },
          legal_entity_docket_seeds: {
            data: [
            {
              id: "@1",
              type: "legal_entity_docket_seed"
            }
            ]
          }
        }
      },
      included:[
        {
          type: "person",
          id: "@1"
        },
        {
          type: "legal_entity_docket_seed",
          id: "@1",
          attributes: {
            industry: "software",
            business_description: "software factory",
            country: "argentina",
            commercial_name: "my soft",
            legal_name: "mySoft SRL"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachment"
              }]
            }
          }
        },
        {
          type: "attachment",
          id: "@1",
          attributes: {
            document: "data:#{content_type};base64,#{attachment.delete!("\n")}",
            document_file_name: file_name,
            document_content_type: content_type
          }
        }
      ]
    }
  end

  def self.issue_with_quota_seed(attachment, content_type, file_name)
    {
      data: {
        type: "issue",
        attributes: {
          
        },
        relationships: {
          person: {
            data: {
              id: "@1",
              type: "person"
            }
          },
          quota_seeds: {
            data: [
            {
              id: "@1",
              type: "quota_seed"
            }
            ]
          }
        }
      },
      included:[
        {
          type: "person",
          id: "@1"
        },
        {
          type: "quota_seed",
          id: "@1",
          attributes: {
            weight: 10,
            amount: 1000,
            kind: "USD"
          },
          relationships: {
            attachments: {
              data: [{
                id: "@1",
                type: "attachment"
              }]
            }
          }
        },
        {
          type: "attachment",
          id: "@1",
          attributes: {
            document: "data:#{content_type};base64,#{attachment.delete!("\n")}",
            document_file_name: file_name,
            document_content_type: content_type
          }
        }
      ]
    }
  end
end