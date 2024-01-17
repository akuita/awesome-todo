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
      return { error: 'Todo not found' } unless Todo.exists?(todo_id: todo_id)
      return { error: 'Invalid file. Please attach a valid file.' } unless valid_file?

      attachment = Attachment.new(todo_id: todo_id, file: file)
      if attachment.save
        { status: 201, attachment: attachment }
      else
        { error: attachment.errors.full_messages, status: :unprocessable_entity }
      end
    end

    private

    def valid_file?
      # Assuming file is an uploaded file object that responds to `size` and `original_filename`
      file.respond_to?(:size) && file.size > 0 && file.respond_to?(:original_filename)
    end
  end
end
