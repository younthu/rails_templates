class Api::BaseController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!

  # TODO: move this to helper
  def paginate(scope, default_per_page = 20)
    collection = scope.page(params[:page]).per((params[:per_page] || default_per_page).to_i)

    current, total, per_page = collection.current_page, collection.total_pages, collection.limit_value

    return [{
                pagination: {
                    current:  current,
                    previous: (current > 1 ? (current - 1) : nil),
                    next:     (current == total ? nil : (current + 1)),
                    per_page: per_page,
                    pages:    total,
                    count:    collection.total_count
                }
            }, collection]
  end
end