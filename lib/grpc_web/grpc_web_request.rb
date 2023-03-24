# frozen_string_literal: true

module GRPCWeb
  GRPCWebRequest = Struct.new(
    :service,
    :service_method,
    :content_type,
    :accept,
    :metadata,
    :body,
  ) do

    def self.get_metadata(request)
      Thread.current[request.object_id.to_s.to_sym]
    end
  end

end
