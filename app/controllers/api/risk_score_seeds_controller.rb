class Api::RiskScoreSeedsController < Api::EntityController
  def resource_class
    RiskScoreSeed
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :risk_scores, :risk_score_seeds],
      issues: [],
      risk_scores: [],
      risk_score_seeds: [
        :score,
        :provider,
        :extra_info,
        :external_link,
        :copy_attachments,
        :replaces,
        :issue,
        :expires_at
      ]
  end
end
