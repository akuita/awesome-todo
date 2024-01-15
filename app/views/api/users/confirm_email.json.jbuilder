{
  "status_code": status
}

if defined?(message)
  json.message message
elsif defined?(error_message)
  json.error_message error_message
end
