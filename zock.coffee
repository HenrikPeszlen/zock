FakeXMLHttpRequest =
  require './components/fake-xml-http-request/fake_xml_http_request'

Router = require 'routes'
URL = require 'url'

class Zock
  routers =
    get: Router()

  base: (@baseUrl) ->
    return this

  get: (@route) ->
    @currentRouter = routers.get
    return this

  reply: (status, body) ->
    unless body
      body = status
      status = 200

    url = (@baseUrl or '') + @route

    @currentRouter.addRoute url, (request) ->
      res = if typeof body == 'function' then body(request) else body

      return {
        statusCode: status
        body: JSON.stringify(res)
      }

    return this

  logger: (logger) ->
    @logger = logger
    return this

  XMLHttpRequest: =>
    log = @logger or -> null
    request = new FakeXMLHttpRequest()
    response = null

    oldOpen = request.open
    oldSend = request.send

    url = null
    method = null

    extractQuery = (url) ->
      parsed = URL.parse url
      obj = {}
      if parsed.query
        for pair in parsed.query.split '&'
          [key, value] = pair.split '='
          obj[key] = value

      return obj

    send = ->
      if not response
        throw new Error("No route for #{method} #{url}")

      queryParams = extractQuery(request.url)

      res = response.fn({params: response.params, query: queryParams})
      status = res.statusCode || 200
      headers = res.headers || {'Content-Type': 'application/json'}
      body = res.body

      respond = -> request.respond(status, headers, body)

      setTimeout respond, 0

    open = (_method, _url) ->
      url = _url
      method = _method

      log "#{method} #{url}"

      parsed = URL.parse url
      delete parsed.query
      delete parsed.hash
      delete parsed.search
      delete parsed.path

      response = routers[method.toLowerCase()]?.match URL.format(parsed)

    request.open = ->
      open.apply null, arguments
      oldOpen.apply request, arguments

    request.send = ->
      send()
      oldSend.apply request, arguments

    return request

module.exports = Zock
