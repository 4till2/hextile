module PostsHelper
  def log_fields(metadata)
    # Only show those fields under 'display'
    metadata = metadata.extract!('details')['details']
    json = metadata.to_json if metadata.present?
    table_options = {
      table_style: '',
      table_class: 'log-table',
      table_attributes: ''
    }

    Json2table::get_html_table(json, table_options) if json.present?
  end
end