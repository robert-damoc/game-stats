class ApplicationController < ActionController::Base
  include Pagy::Backend
  PER_PAGE = 20
end
