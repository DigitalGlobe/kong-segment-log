# kong-segment-log

A [Kong](https://getkong.org) plugin that sends request logs to [Segment](https://segment.com)'s [track() API](https://segment.com/docs/sources/server/http/#track).

## Current Design

* It expects incoming requests to contain a JWT in the Authorization header, and otherwise logs an error.
* The JWT is decoded (not validated) to obtain the ID of the user making the request.  
    *See `config.jwt_payload_key__user_id`*
* A user event is sent to Segment's track() API with this data:

    ```
    {
        userId: 'abc123', // the user ID from the decoded JWT
        event: 'POST /articles/*/comments', // `"<request_method> <request_path>"` (See `config.glob_event_name_paths`)
        properties: {
            method: 'POST', // The HTTP method of the request
            path: '/articles/abc123/comments', // The path of the request
            uri: 'http://example.com/articles/abc123/comments', // The full URI of the request
            querystring: '{"options": true}', // The JSON encoded querystring data as parsed by Kong.
            timeOfProxy: 123, // In ms, from Kong's latencies.proxy
            timeOfKong: 45, // In ms, from Kong's latencies.kong
            timeOfRequest: 678, // In ms, from Kong's latencies.request
            statusCode: 200, // Integer status code of the response
        },
        context: {
            ip: '100.0.0.1', // From Kong's `client_ip`
            userAgent: 'curl', // From the request's `User-Agent` header
        },
        timestamp: From Kong's `started_at`, converted to ISO8601 timestamp
    }
    ```

## Installation & Usage
1. Install `kong-segment-log` via Luarocks
    ```
    $ luarocks install kong-segment-log
    ```
1. Add the `segment-log` plugin to your Kong Configuration

    ##### Kong v0.9.x
    In `kong.conf`, list the `segment-log` plugin in your `custom_plugins` configuration, e.g.
    ```
    custom_plugins = segment-log,another-custom-plugin
    ```

    ##### Kong v0.6.x – v0.8.x
    In `kong.yml`, list the `segment-log` plugin under `custom_plugins`, e.g.
    ```
    custom_plugins:
      - segment-log
    ```

    ##### Kong v0.5.x
    In `kong.yml`, list the `segment-log` plugin under `plugins_available`, e.g.
    ```
    plugins_available:
      - segment-log
    ```
1. Activate the `segment-log` plugin via Kong's API
    ```
    curl -s -X POST http://localhost:8001/plugins/ --data name=segment-log --data config.segment_write_key=abc123
    ```
    Available configuration:

    Name | Type | Required | Default | Description / Notes
    ---- | ---- | -------- | ------- | -------------------
    config.segment_write_key | string | yes | None | The "write key" for your Segment Source – comes from your segment source > Settings
    config.jwt_payload_key__user_id | string | no | `"sub"` | The name of the property from the JWT payload whose value contains the user ID
    config.glob_event_name_paths | boolean | no | `true` | Whether to glob routes containing numeric path components in the event name. If `true`, A POST request to `/articles/abc123/comments` will be tracked in Segment with the event name `POST /articles/*/comments`. If `false`, the event name will be `POST /articles/abc123/comments`. The original request path is always available in the Segment event's properties, as `path`.
    config.timeout | number | no | `10000` | Timeout for the request to Segment, in ms
    config.keepalive | number | no | `60000` | Keepalive for the request to Segment, in ms
