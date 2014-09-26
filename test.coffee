chai = require 'clay-chai'
chai.should()

Zock = new require('./zock.coffee')

describe 'zock', ->
  it 'should get', (done) ->
    xmlhttp = new Zock()
      .base('http://baseurl.com')
      .get('/test')
      .reply(200, {hello: 'world'}).XMLHttpRequest()

    xmlhttp.onreadystatechange = ->
      if xmlhttp.readyState == 4
        res = xmlhttp.responseText
        res.should.be JSON.stringify({hello: 'world'})
        done()

    xmlhttp.open('get', 'http://baseurl.com/test')
    xmlhttp.send()

  it 'should post', (done) ->
    xmlhttp = new Zock()
      .base('http://baseurl.com')
      .post('/test')
      .reply(200, {hello: 'post'}).XMLHttpRequest()

    xmlhttp.onreadystatechange = ->
      if xmlhttp.readyState == 4
        res = xmlhttp.responseText
        res.should.be JSON.stringify({hello: 'post'})
        done()

    xmlhttp.open('post', 'http://baseurl.com/test')
    xmlhttp.send()

  it 'should get multiple at the same time', (done) ->
    XML = new Zock()
      .base('http://baseurl.com')
      .get('/test')
      .reply(200, {hello: 'world'})
      .get('/hello')
      .reply(200, {test: 'test'}).XMLHttpRequest


    resCnt = 0
    xmlhttp = new XML()
    xmlhttp.onreadystatechange = ->
      if xmlhttp.readyState == 4
        res = xmlhttp.responseText
        res.should.be JSON.stringify({hello: 'world'})
        if ++resCnt == 2
          done()

    xmlhttp2 = new XML()
    xmlhttp2.onreadystatechange = ->
      if xmlhttp2.readyState == 4
        res = xmlhttp2.responseText
        res.should.be JSON.stringify({test: 'test'})
        if ++resCnt == 2
          done()


    xmlhttp.open('get', 'http://baseurl.com/test')
    xmlhttp2.open('get', 'http://baseurl.com/hello')
    xmlhttp.send()
    xmlhttp2.send()

  it 'should ignore query params and hashes', (done) ->
    xmlhttp = new Zock()
      .base('http://baseurl.com')
      .get('/test')
      .reply(200, {hello: 'world'}).XMLHttpRequest()

    xmlhttp.onreadystatechange = ->
      if xmlhttp.readyState == 4
        res = xmlhttp.responseText
        res.should.be JSON.stringify({hello: 'world'})
        done()

    xmlhttp.open('get', 'http://baseurl.com/test?test=123#hash')
    xmlhttp.send()

  it 'logs', (done) ->
    log = 'null'

    xmlhttp = new Zock()
      .logger (x) -> log = x
      .base('http://baseurl.com')
      .get('/test')
      .reply(200, {hello: 'world'}).XMLHttpRequest()

    xmlhttp.onreadystatechange = ->
      if xmlhttp.readyState == 4
        log.should.be 'get http://baseurl.com/test?test=123#hash'
        done()

    xmlhttp.open('get', 'http://baseurl.com/test?test=123#hash')
    xmlhttp.send()

  it 'has optional status', (done) ->
    xmlhttp = new Zock()
      .base('http://baseurl.com')
      .get('/test')
      .reply({hello: 'world'}).XMLHttpRequest()

    xmlhttp.onreadystatechange = ->
      if xmlhttp.readyState == 4
        res = xmlhttp.responseText
        res.should.be JSON.stringify({hello: 'world'})
        done()

    xmlhttp.open('get', 'http://baseurl.com/test')
    xmlhttp.send()

  it 'supports functions for body', (done) ->
    xmlhttp = new Zock()
      .base('http://baseurl.com')
      .get('/test/:name')
      .reply (res) ->
        return res
      .XMLHttpRequest()

    xmlhttp.onreadystatechange = ->
      if xmlhttp.readyState == 4
        res = xmlhttp.responseText
        parsed = JSON.parse(res)
        parsed.params.name.should.be 'joe'
        parsed.query.q.should.be 't'
        parsed.query.p.should.be 'plumber'

        done()

    xmlhttp.open('get', 'http://baseurl.com/test/joe?q=t&p=plumber')
    xmlhttp.send()
