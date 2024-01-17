module AttachmentService
  class Create < BaseService
    def initialize(todo_id, file)
      @todo_id = todo_id
      @file = file
    end

    def call
      return { error: 'Todo ID is missing', status: 400 } unless @todo_id.present?
      return { error: 'Invalid file. Please attach a valid file.', status: 400 } unless @file.present?

      todo = Todo.find_by_id(@todo_id)
      return { error: 'Todo not found.', status: 400 } if todo.nil?

      attachment = Attachment.new(todo_id: @todo_id, file: @file)
      if attachment.save
        { status: 201, attachment: attachment.as_json }
      else
        { error: attachment.errors.full_messages.join(', '), status: 422 }
      end
    end
  end
end
