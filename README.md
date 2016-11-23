# kong-segment-log

A [Kong](https://getkong.org) plugin that sends request logs to [Segment](https://segment.com)'s [track() API](https://segment.com/docs/sources/server/http/#track).

## Current Design

* It expects incoming requests to contain a JWT in the Authorization header, and otherwise logs an error.
* The JWT is decoded (not validated) to obtain the ID of the user making the request.  
    *See `config.jwt_payload_key__user_id`*
* A user event is sent to Segment's track() API with this data:

    ```
    {
        userId: 'u123', // the user ID from the decoded JWT
        event: 'POST /articles/a123/comments', // (See config.event_name_template)
        properties: {
            method: 'POST', // The HTTP method of the request
            uri: 'http://example.com/articles/abc123/comments', // The full URI of the request
            protocol: 'https', // The protocol of the request
            host: 'example.com', // The host of the request
            port: 443, // The port of the request
            path: '/articles/a123/comments', // The path of the request
            pathComponent1: 'articles', // The first path component of the request
            pathComponent2: 'a123',
            pathComponent3: 'comments',
            pathComponent4: undefined,
            pathComponent5: undefined,
            pathComponent6: undefined,
            pathComponent7: undefined,
            pathComponent8: undefined,
            pathComponent9: undefined,
            pathComponent10: undefined,
            querystring: {options: true}, // The querystring data as parsed by Kong.
            querystringJson: '{"options": true}', // The JSON-encoded querystring data as parsed by Kong.
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
    # Or, optionally, specify a version to install: (this version is not real)
    $ luarocks install kong-segment-log 10.0.0-1
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
    config.event_name_template | string | no | `"API Request: {method}"` | Template for the event name as sent to Segment. Available template values: `{method}`, `{path}`, `{host}`
    config.strip_trailing_slash | boolean | no | `true` | If `true`, strips the trailing slash from the `{path}` parameter in the event name template.
    config.timeout | number | no | `10000` | Timeout for the request to Segment, in ms
    config.keepalive | number | no | `60000` | Keepalive for the request to Segment, in ms

## Example shell script for injecting the custom plugin into your configuration file.

```
# Check for custom plugin segment-log
cat /etc/kong/kong.yml | grep "segment-log"
if [ $? -eq 0 ]; then
	echo "custom plugin segment-log already configured";
else
	echo "add custom plugin to kong.yml";
	# This command inserts the text `  - segment-log` directly after the line containing `plugins_available:`.
	sed -i '/plugins_available:/a \  - segment-log' /etc/kong/kong.yml
fi
```

## How to publish on Luarocks

[Luarocks Docs: Publishing your code online](https://github.com/luarocks/luarocks/wiki/Creating-a-rock#publishing-your-code-online)

1. Update the `kong-segment-log-*.rockspec` file:
    * Update `version` and `source.tag` with a new version number.
    * Rename the file to update the version number to match.
    * Commit & push to github.
1. Tag your commit and push the tag to github (or use github's Releases feature, where you can add a better description):
    ```
    $ git tag -a v1.0.0 -m 'Big updates!'
    $ git push --tags
    ```
1. Upload the rock to Luarocks:
    ```
    $ luarocks upload kong-segment-log-*.rockspec --api-key=<your API key>
    ```
