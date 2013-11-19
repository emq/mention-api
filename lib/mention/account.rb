module Mention
  class Account
    def initialize(credentials)
      @account_id = credentials.fetch(:account_id)
      @access_token = credentials.fetch(:access_token)
    end

    def alerts
      @alerts ||= begin
        raw_data = JSON.parse(connection.get('/alerts'))
        raw_data['alerts'].map do |hash|
          Alert.new(hash)
        end
      end
    end

    def name
      account_info['account']['name']
    end

    def id
      account_info['account']['id']
    end

    def email
      account_info['account']['email']
    end

    def created_at
      Time.parse(account_info['account']['created_at'])
    end

    def add(alert)
      creator = AlertCreator.new(connection, alert)
      @alerts = nil if creator.valid?
      creator.created_alert
    end

    def remove_alert(alert, share)
      connection.delete("/alerts/#{alert.id}/shares/#{share.id}")
    end

    def update(alert)
      creator = AlertCreator.new(connection, alert, :update)
      @alerts = nil if creator.valid?
      creator.created_alert
    end

    def update_alert_preferences(alert, params)
      response = connection.put("/alerts/#{alert.id}/preferences", JSON.generate(params), 'Content-Type' => 'application/json')
      JSON.parse(response)
    end

    def alert_preferences(alert)
      JSON.parse(connection.get("/alerts/#{alert.id}/preferences"))
    end

    def fetch_mentions(alert, params = {})
      raw_data = JSON.parse(connection.get("/alerts/#{alert.id}/mentions", params))
      MentionList.new(raw_data)
    end

    private
    attr_reader :account_id, :access_token

    def connection
      @connection ||= Connection.new(account_id, access_token)
    end

    def account_info
      @account_info ||= JSON.parse(connection.get)
    end
  end
end
