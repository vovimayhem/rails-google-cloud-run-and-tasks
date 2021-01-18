class GoogleIdToken
  include ActiveModel::Validations

  attr_reader :token, :header, :payload

  validates :token, presence: true

  validate :audience_matches_project_id,
           :issuer_matches_the_expected_issuer,
           :expires_in_the_future,
           :issued_in_the_past,
           :authenticated_in_the_past

  def initialize(token)
    @token = token
    @payload, @header = JWT.decode(@token, nil, false)
                           .map(&:with_indifferent_access)
  end

  def issuer
    payload[:iss]
  end

  def audience
    payload[:aud]
  end

  def user_id
    payload[:user_id]
  end

  def subject
    payload[:sub]
  end

  # Only available with email+password provider:
  def email
    payload[:email]
  end

  # Only available with email+password provider:
  def email_verified
    payload[:email_verified]
  end

  def authenticated_at
    @authenticated_at ||= Time.at(payload[:auth_time])
  end

  def issued_at
    @issued_at ||= Time.at(payload[:iat])
  end

  def expires_at
    @expires_at ||= Time.at(payload[:exp])
  end

  def self.project_id
    ENV.fetch 'GOOGLE_CLOUD_PROJECT'
  end

  delegate :project_id, to: :class, prefix: :configured

  def user
    User.new id: user_id, email: email, email_verified: email_verified
  end

  protected

  def expires_in_the_future
    return if Time.now < expires_at

    errors.add :token, 'has expired'
  end

  def issued_in_the_past
    return if Time.now > issued_at

    errors.add :token, 'issued at invalid date'
  end

  def authenticated_in_the_past
    return if Time.now > authenticated_at

    errors.add :token, 'authenticated at invalid date'
  end

  def audience_matches_project_id
    return if audience == configured_project_id

    errors.add :token, "unexpected audience '#{audience}'"
  end

  def issuer_matches_the_expected_issuer
    return if issuer == "https://securetoken.google.com/#{configured_project_id}"

    errors.add :token, "unexpected issuer '#{issuer}'"
  end
end
