require 'spec_helper'
class Api::SeedsHelper
  include RSpec::Rails::FixtureFileUploadSupport

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
end
