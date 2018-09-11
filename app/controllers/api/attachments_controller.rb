class Api::AttachmentsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s|
      s.person.
      attachments.
      where(attached_to_seed_id:
        params.select{|x| x.include? 'seed_id'}.values.first)}
  end

  def get_resource(scope)
    scope
     .person
     .attachments.find(params[:id])
  end

  def options_for_response
    {
      include: []
    }
  end
end
