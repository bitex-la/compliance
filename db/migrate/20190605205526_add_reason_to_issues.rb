Dir[Rails.root.join("app/serializers/**/*.rb")].each {|f| require f}
class AddReasonToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :reason_id, :integer

    # 1 -> first issue of every person has new_client reason
    Person.all.find_each do |p| 
      issue = p.issues.first
      next if issue.nil?
      issue.update_column(:reason_id, IssueReason.new_client.id) 
    end

    # 5 -> issue with a risk score has new_risk_information reason
    Issue.joins(:risk_score_seeds)
      .where('reason_id is null')
      .update_all(reason_id: IssueReason.new_risk_information.id)

    # 3 -> issue with defer_until > created_at has update_expired_data reason 
    Issue.where('reason_id is null and defer_until is not null and defer_until > created_at')
      .update_all(reason_id: IssueReason.update_expired_data.id)

    # 2 -> other issues has further_clarification reason
    Issue.where('reason_id is null')
      .update_all(reason_id: IssueReason.further_clarification.id)

    change_column_null :issues, :reason_id, false
  end
end
