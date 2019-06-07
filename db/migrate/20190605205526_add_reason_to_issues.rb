Dir[Rails.root.join("app/serializers/**/*.rb")].each {|f| require f}
class AddReasonToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :reason_id, :integer, null:true

    # 1 -> first issue of every person has new_client reason
    Person.all.each do |p| 
      issue = p.issues.first
      next if issue.nil?
      issue.update_attribute(:reason,IssueReason.new_client) 
    end

    # 5 -> issue with a risk score has new_risk_information reason
    Issue.joins(:risk_score_seeds)
      .where('reason_id is null').each do |i|
      i.update_attribute(:reason,IssueReason.new_risk_information) 
    end

    # 3 -> issue with defer_until > created_at has update_expired_data reason 
    Issue.where('defer_until is not null and defer_until > created_at').each do |i|
      i.update_attribute(:reason,IssueReason.update_expired_data) 
    end

    # 2 -> other issues has further_clarification reason
    Issue.where('reason_id is null').each do |i|
      i.update_attribute(:reason,IssueReason.further_clarification) 
    end

    change_column_null :issues, :reason_id, false
  end
end
