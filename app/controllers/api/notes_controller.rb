
class Api::NotesController < ApplicationController
  def create
    @note = current_user.notes.build(note_params)
    if @note.save
      render json: {
        validation_status: true,
        note: @note
      }, status: :created
    else
      render json: {
        validation_status: false,
        error_message: @note.errors.full_messages.join(', ')
      }, status: :unprocessable_entity
    end
  end
end
