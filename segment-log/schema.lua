return {
  fields = {
    segment_write_key = { required = true, type = "string" },
    jwt_payload_key__user_id = { default = "sub", type = "string" },
    event_name_template = { default = "API Request: {method}", type = "string" },
    strip_trailing_slash = { default = true, type = "boolean" },
    timeout = { default = 10000, type = "number" },
    keepalive = { default = 60000, type = "number" }
    -- http_endpoint = { required = true, type = "url" },
    -- method = { default = "POST", enum = { "POST", "PUT", "PATCH" } },
  }
}
