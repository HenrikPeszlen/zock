FakeXMLHttpRequest =
  require './components/fake-xml-http-request/fake_xml_http_request'

Router = require('routes')

class Zock
  routers =
    get: Router()

  base: (@baseUrl) ->
    return this

  get: (@route) ->
    @currentRouter = routers.get
    return this

  reply: (status, body) ->
    url = @baseUrl + @route

    @currentRouter.addRoute url, ->
      return {
        statusCode: status
        body: JSON.stringify(body)
      }

    return this

  backup: (@XMLHttpRequest) ->
    return

  XMLHttpRequest: =>
    backup = @backup
    request = new FakeXMLHttpRequest()
    response = null

    oldOpen = request.open
    oldSend = request.send

    url = null
    method = null

    send = ->
      if not response
        throw new Error("No route for #{method} #{url}")

      res = response.fn()
      status = res.statusCode || 200
      headers = res.headers || {'Content-Type': 'application/json'}
      body = res.body

      respond = -> request.respond(status, headers, body)

      setTimeout respond, 0

    open = (_method, _url) ->
      url = _url
      method = _method
      response = routers[method.toLowerCase()].match url

    request.open = ->
      open.apply null, arguments
      oldOpen.apply request, arguments

    request.send = ->
      send()
      oldSend.apply request, arguments

    return request

module.exports = Zock
