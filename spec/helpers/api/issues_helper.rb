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

  def self.issue_with_domicile_seed(attachment, content_type, file_name)
    {
      data: {
        id: "@1",
        type: "issues",
        attributes: {
          
        },
        relationships: {
          domicile_seed: {
            data: {
              id: "@1",
              type: "domicile_seeds"
            }
          }
        }
      },
      included: [
        {
          type: "domicile_seeds",
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
        {
          type: "attachments",
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
        type: "issues",
        attributes: {
          
        },
        relationships: {
          identification_seed: {
            data: 
            {
              id: "@1",
              type: "identification_seeds"
            }            
          }
        }
      },
      included:[
        {
          type: "identification_seeds",
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
                type: "attachments"
              }]
            }
          }
        },
        {
          type: "attachments",
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
            birth_date: "1985-10-08",
            nationality: "argentina",
            gender: "male",
            marital_status: "single"
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
        {
          type: "attachments",
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
            country: "argentina",
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
        {
          type: "attachments",
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

  def self.issue_with_allowance_seed(attachment, content_type, file_name)
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
            kind: "USD"
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
        {
          type: "attachments",
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
