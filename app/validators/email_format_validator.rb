require 'uri/mailto'

class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ URI::MailTo::EMAIL_REGEXP
      # The new code does not include the custom message, so we need to merge the existing code's custom message functionality.
      # We will use the I18n internationalization library to provide a localized error message.
      record.errors.add(attribute, :invalid, message: I18n.t('errors.messages.invalid_email', value: value))
    end
  end
end
