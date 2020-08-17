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
end
