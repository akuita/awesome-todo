
module AttachmentService
  class Create < BaseService
    def initialize(todo_id, file)
      @todo_id = todo_id
      @file = file
    end

    def call
      return { error: 'Todo ID is missing', status: 400 } unless @todo_id.present?
      return { error: 'Invalid file. Please attach a valid file.', status: 400 } unless @file.present?

      todo = Todo.find_by(id: @todo_id) # Ensure todo exists
      return { error: 'Todo not found.', status: 400 } if todo.nil?

      attachment = Attachment.new(todo_id: @todo_id, file: @file)
      attachment.file.attach(@file) # Patched line: Attach the file to the attachment

      unless attachment.valid?
        return { error: attachment.errors.full_messages.join(', '), status: 422 }
      end

      # Validate file content type and size
      allowed_content_types = ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf']
      if @file.respond_to?(:content_type) # Patched line: Check if @file responds to content_type
        unless allowed_content_types.include?(@file.content_type)
          return { error: 'Invalid file type. Allowed types are: PNG, JPG, JPEG, PDF.', status: 422 }
        end
      end

      if @file.respond_to?(:size) # Patched line: Check if @file responds to size
        if @file.size > 10.megabytes
          return { error: 'File size exceeds the allowed limit of 10MB.', status: 422 }
        end
      end

      if attachment.save
        { status: 201, attachment: attachment.as_json }
      else
        { error: attachment.errors.full_messages.join(', '), status: 422 }
      end
    end
  end
end
