class Api::DomicileSeedsController < ApplicationController
  def show
    domicile_seed = DomicileSeed.find(params[:id])
    render json: DomicileSeedSerializer.new(domicile_seed).serialized_json
  end
end
