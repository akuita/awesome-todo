# frozen_string_literal: true

module AttachmentService
  class Create
    attr_reader :todo_id, :file

    def initialize(todo_id, file)
      @todo_id = todo_id
      @file = file
    end

    def call
      return { error: 'Todo ID and file are required' } unless todo_id && file

      attachment = Attachment.new(todo_id: todo_id, file: file)
      return { error: attachment.errors.full_messages } unless attachment.save

      attachment
    end
  end
end
