if Rails.env == "production" || Rails.env == "staging" || Rails.env == "development"

  exceptions = []
  exceptions << 'ActiveRecord::RecordNotFound'
  exceptions << 'AbstractController::ActionNotFound'
  exceptions << 'ActionController::RoutingError'
  exceptions << 'ActionController::InvalidAuthenticityToken'
  exceptions << 'ActionView::MissingTemplate'

  Rails.application.config.middleware.use ExceptionNotification::Rack,
  :email => {
    :sender_address => %{"Scrap Dragon Portal Exception Notifier" <info@scrapdragon.com>},
    :exception_recipients => %w{jeremy@tranact.com shark@tranact.com}
  },
  ignore_exceptions: exceptions

end