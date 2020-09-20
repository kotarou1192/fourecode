# frozen_string_literal: true

module ErrorMessageHelper
  extend ActiveSupport::Concern
  include ResponseStatus
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
    errors.push(key: key, messages: [message], code: code) if key
    { errors: errors }
  end

  def error_response(status: 400, json:)
    render status: status, json: json
  end

  def failed_to_create(model)
    messages = generate_error_messages_from_errors(model.errors.messages)
    error_response json: generate_response(ResponseStatus::FAILED, nil)
                           .merge(error_messages(error_messages: messages))
  end

  def old_token_response(type: 'onetime')
    raise ArgumentError, "undefined type #{type}. type should be #{TOKEN_TYPES.join(' or ')}" unless TOKEN_TYPES.any? type

    message = "#{type} token is too old"
    error_response json: generate_response(ResponseStatus::FAILED, message: message)
                           .merge(error_messages(key: 'token', message: message))
  end
end
