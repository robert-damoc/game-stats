class ApplicationController < ActionController::Base
  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found(exception)
    raise exception if Rails.env.development?

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end
end
