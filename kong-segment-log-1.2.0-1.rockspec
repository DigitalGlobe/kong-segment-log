package = "kong-segment-log"
version = "1.2.0-1"
source = {
  url = "git://github.com/DigitalGlobe/kong-segment-log",
  tag = "v1.2.0-1",
}
description = {
  summary = "A Kong plugin that sends request logs to Segment track() API to track user activity.",
  license = "MIT"
}
dependencies = {
  "lua ~> 5.1"
  -- If you depend on other rocks, add them here
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.segment-log.schema"] = "segment-log/schema.lua",
    ["kong.plugins.segment-log.handler"] = "segment-log/handler.lua",
    ["kong.plugins.segment-log.jwt_parser"] = "segment-log/jwt_parser.lua"
  }
}
