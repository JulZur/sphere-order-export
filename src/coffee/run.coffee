Mapping = require '../lib/mapping'
SphereClient = require 'sphere-node-client'
package_json = require '../package.json'
fs = require 'fs'
argv = require('optimist')
  .usage('Usage: $0 --projectKey key --clientId id --clientSecret secret')
  .default('timeout', 300000)
  .describe('projectKey', 'your SPHERE.IO project-key')
  .describe('clientId', 'your OAuth client id for the SPHERE.IO API')
  .describe('clientSecret', 'your OAuth client secret for the SPHERE.IO API')
  .describe('timeout', 'Set timeout for requests')
  .demand(['projectKey', 'clientId', 'clientSecret'])
  .argv

options =
  config:
    project_key: argv.projectKey
    client_id: argv.clientId
    client_secret: argv.clientSecret
  timeout: argv.timeout
  user_agent: "#{package_json.name} - #{package_json.version}"
#  xsd: './schema/order.xsd'

sphere = new SphereClient options
mapping = new Mapping options

sphere.orders.fetch().then (result) ->
  mapping.mapOrders result, (xmlOrders) ->
    for entry in xmlOrders
      content = entry.xml.end(pretty: true, indent: '  ', newline: "\n")
      fileName = "#{entry.id}.xml"
      fs.writeFile fileName, content, (err) ->
        if err
          console.log err
          process.exit 2

.fail (res) ->
  console.log res
  process.exit 1