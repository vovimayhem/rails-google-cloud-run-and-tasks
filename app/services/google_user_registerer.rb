# frozen_string_literal: true

# GoogleUserRegisterer
#
# NOTES: Make sure your service account has the role "Identity Platform Admin"
#
# See:
# - https://cloud.google.com/identity-platform/docs/reference/rest/v1/accounts/signUp
class GoogleUserRegisterer
  AUTH_SCOPE = 'https://www.googleapis.com/auth/cloud-platform'
  REQUEST_URI = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp'

  include Performable

  attr_reader :email, :password, :display_name

  def initialize(email:, password: nil, display_name: nil)
    @email = email
    @password = password
    @display_name = display_name
  end

  def response
    @response ||= client.fetch_protected_resource(
      uri: REQUEST_URI,
      method: 'POST',
      headers: { 'Content-Type' => 'application/json' },
      body: request_body
    )
  end

  def perform!
    response
  end
  
  delegate :client, to: :credentials

  def credentials
    @credentials ||= Google::Auth::Credentials.default scope: AUTH_SCOPE
  end

  protected




  def request_body
    { email: @email, password: @password, displayName: @display_name}
      .compact
      .to_json
  end
end
