
# typed: true
class BaseService
  def initialize(*_args); end

  def logger
    @logger ||= Rails.logger
  end
end

class FigmaImportService < BaseService
  attr_reader :project_id, :figma_file_id

  def initialize(project_id, figma_file_id)
    @project_id = project_id
    @figma_file_id = figma_file_id
  end

  def call
    validate_project!
    validate_figma_file_id!
    # Assuming `fetch_design_from_figma` is a method that makes an API request to Figma
    design_elements = fetch_design_from_figma(figma_file_id)
    create_figma_import_record!
    use_cases_count = parse_and_create_use_cases(design_elements)
    { import_status: 'success', imported_use_cases_count: use_cases_count }
  rescue StandardError => e
    create_error_record!(e.message)
    { import_status: 'failed', error_message: e.message }
  end

  private

  def validate_project!
    raise 'Project not found.' unless Project.exists?(project_id)
  end

  def validate_figma_file_id!
    raise 'Figma file ID is required.' if figma_file_id.blank?
    raise 'Invalid Figma file ID.' unless figma_file_id =~ /^[0-9a-zA-Z_]+$/ # Example regex for validation
  end

  def create_figma_import_record!
    FigmaImport.create!(
      project_id: project_id,
      figma_file_id: figma_file_id,
      imported_at: Time.current
    )
  end

  def parse_and_create_use_cases(design_elements)
    # Assuming `parse_design_elements` is a method that parses design elements and returns use cases
    use_cases = parse_design_elements(design_elements)
    use_cases.each do |use_case|
      UseCase.create!(
        project_id: project_id,
        title: use_case[:title],
        description: use_case[:description],
        created_at: Time.current
      )
    end
    use_cases.count
  end

  def create_error_record!(message)
    Error.create!(
      project_id: project_id,
      message: message,
      timestamp: Time.current
    )
  end
end
