class Util::PageCalculator
  def self.call(params, default_page = 0, default_per = 10)
    if !params[:page].blank?
      page     = !params[:page][:page].nil? ? params[:page][:page].to_i :  default_page
      per_page = !params[:page][:per_page].nil? ? params[:page][:per_page].to_i : default_per
      [page, per_page]
    else
      [default_page, default_per]
    end
  end
end
