class Util::PageCalculator
  def self.call(params, default_page = 0, default_per = 10)
    page     = !params[:page].nil? ? params[:page].to_i :  default_page
    per_page = !params[:per_page].nil? ? params[:per_page].to_i : default_per
    [page, per_page]
  end
end