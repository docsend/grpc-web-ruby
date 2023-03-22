# frozen_string_literal: true

module GRPCWeb
  GRPCWebRequest = Struct.new(
    :service,
    :service_method,
    :content_type,
    :accept,
    :metadata,
    :body,
  )
end
