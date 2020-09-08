# frozen_string_literal: true

module ErrorMessageHelper
  extend ActiveSupport::Concern

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
    error_response json: generate_response(FAILED, nil)
                           .merge(error_messages(error_messages: messages))
  end
end
