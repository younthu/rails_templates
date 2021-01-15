class Api::BaseController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_user!

  # TODO: move this to helper, 兼容Array
  # 使用方法:
  #   render json: paginate(cmts, include: {author:{methods: :followed}, resource: {}, comments:{}, topic: {}})
  def paginate(scope, default_per_page = 20, **options)
    if scope.is_a? Array
      collection = Kaminari.paginate_array(scope).page(params[:page]).per((params[:per_page] || default_per_page).to_i)
    else
      collection = scope.page(params[:page]).per((params[:per_page] || default_per_page).to_i)
    end


    current, total, per_page = collection.current_page, collection.total_pages, collection.limit_value

    return {
        pagination: {
            current:  current,
            previous: (current > 1 ? (current - 1) : nil),
            next:     (current == total ? nil : (current + 1)),
            per_page: per_page,
            pages:    total,
            count:    collection.total_count
        }, items: collection.as_json(options)}
  end
end