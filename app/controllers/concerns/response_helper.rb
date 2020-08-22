module ResponseHelper
  extend ActiveSupport::Concern

  def generate_response(status, body)
    {
      status: status,
      body: body
    }
  end
end