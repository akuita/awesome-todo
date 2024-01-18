module AttachmentService
  class Create < BaseService
    def initialize(todo_id, files)
      @todo_id = todo_id
      @files = Array(files) # Ensure files is an array
    end

    def call
      return { error: 'Todo ID is missing', status: 400 } unless @todo_id.present?
      return { error: 'Invalid file. Please attach a valid file.', status: 400 } unless @files.all?(&:present?)

      todo = Todo.find_by(id: @todo_id) # Ensure todo exists
      return { error: 'Todo not found.', status: 400 } if todo.nil?

      attachments = []
      errors = []

      @files.each do |file|
        attachment = Attachment.new(todo_id: @todo_id, file: file)
        attachment.file.attach(file) if file.respond_to?(:attach) # Patched line: Attach the file to the attachment

        unless attachment.valid?
          errors << attachment.errors.full_messages
          next
        end

        # Validate file content type and size
        allowed_content_types = ['image/png', 'image/jpg', 'image/jpeg', 'application/pdf']
        if file.respond_to?(:content_type) # Patched line: Check if file responds to content_type
          unless allowed_content_types.include?(file.content_type)
            errors << 'Invalid file type. Allowed types are: PNG, JPG, JPEG, PDF.'
            next
          end
        end

        if file.respond_to?(:size) # Patched line: Check if file responds to size
          if file.size > 10.megabytes
            errors << 'File size exceeds the allowed limit of 10MB.'
            next
          end
        end

        if attachment.save
          attachments << attachment
        else
          errors << attachment.errors.full_messages
        end
      end

      return { error: errors.join(', '), status: 422 } if errors.any?

      if attachments.size == 1
        { status: 201, attachment: attachments.first.as_json } # Single attachment response
      else
        { status: 201, attachments: attachments.map(&:as_json) } # Multiple attachments response
      end
    end
  end
end
