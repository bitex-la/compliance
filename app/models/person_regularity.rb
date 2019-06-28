class PersonRegularity
  include StaticModels::Model

  static_models_dense [
    [:id,   :code],
    [1,     :none],
    [2,     :low],
    [3,     :high]
  ]

  def applies?(sum, count)
    return true if self == self.class.all.first
    sum >= funding_amount || count >= funding_count
  end

  %w(funding_amount funding_count).each do |x| 
    define_method(x) do 
      return 0 if code == :none
      Settings.regularities[code][x]  
    end
  end
end
