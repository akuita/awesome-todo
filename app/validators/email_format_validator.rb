require 'uri/mailto'

class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ URI::MailTo::EMAIL_REGEXP
      record.errors.add(attribute, :invalid, message: I18n.t('errors.messages.invalid_email', value: value))
    end
  end
end

