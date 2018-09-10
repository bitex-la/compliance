class Api::SystemsController < Api::ApiController
  def truncate
    System.truncate
    render json: {data: {status: 'success'}}
  end
end
