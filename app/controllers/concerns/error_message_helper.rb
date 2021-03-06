# frozen_string_literal: true

module ErrorMessageHelper
  extend ActiveSupport::Concern
  include ResponseStatus
  include ResponseHelper
  include ErrorKeys

  TOKEN_TYPES = %w[onetime master].freeze

  def generate_error_messages_from_errors(messages)
    messages.map do |key, value|
      {
        messages: value,
        key: key,
        code: nil
      }
    end
  end

  def error_messages(key: nil, message: nil, code: nil, error_messages: [])
    errors = error_messages
    is_exists = false
    errors.each do |error|
      next unless error[:key] == key

      error[:messages].push message
      is_exists = true
      break
    end
    errors.push(key: key, messages: [message], code: code) if key && !is_exists
    { errors: errors }
  end

  def error_response_base(status: 400, json:)
    render status: status, json: json
  end

  def error_response(key:, message:, status: 400)
    error_response_base status: status, json: generate_response(ResponseStatus::FAILED, nil)
                                                .merge(error_messages(key: key, message: message))
  end

  def failed_to_create(model)
    messages = generate_error_messages_from_errors(model.errors.messages)
    error_response_base json: generate_response(ResponseStatus::FAILED, nil)
                                .merge(error_messages(error_messages: messages))
  end

  def old_token_response(type: 'onetime')
    raise ArgumentError, "undefined type #{type}. type should be #{TOKEN_TYPES.join(' or ')}" unless TOKEN_TYPES.any? type

    message = "#{type} token is too old"
    error_response_base json: generate_response(ResponseStatus::FAILED, message: message)
                                .merge(error_messages(key: ErrorKeys::TOKEN, message: message))
  end
end
