module Mention
  class AlertCreator
    def initialize(connection, alert, mode = :create)
      @connection, @alert, @mode = connection, alert, mode
    end

    def created_alert
      @created_alert ||= Alert.new(response['alert'])
    end

    def valid?
      validate_response!
      true
    end

    private
    attr_reader :connection, :alert, :mode

    def create?
      mode == :create
    end

    def response
      @response ||= JSON.parse(http_response)
    end

    def http_response
      @http_response ||= if create?
        connection.post("/alerts", *params)
      else
        connection.put("/alerts/#{alert.id}", *params)
      end
    end

    def params
      [JSON.generate(request_params), 'Content-Type' => 'application/json']
    end

    def request_params
      alert.attributes.reject { |k,v| k == :id || k == :shares }
    end

    def validate_response!
      raise ValidationError.new(validation_errors.join(", ")) unless response['alert']
    end

    def validation_errors
      aggregate_errors(response)
    end

    def aggregate_errors(hash_node, list = [])
      if !hash_node.is_a?(Hash)
        []
      elsif hash_node['errors']
        hash_node['errors']
      else
        error_lists = hash_node.map do |key, node|
          aggregate_errors(node)
        end
        error_lists.inject([]) do |list, node_list|
          list + node_list
        end
      end
    end
  end
end
