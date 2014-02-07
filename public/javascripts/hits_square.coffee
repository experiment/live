class @HitsSquare
  constructor: (opts) ->
    @size = opts.size || 500;
    @regex = opts.regex || /.*/
    @hits = []

    @$el = $(opts.el)
    @_init opts.el

  _init: (el) ->
    @svg = d3.select(el)
      .append('svg:svg')
      .attr('width', @size + 'px')
      .attr('height', @size + 'px')

    @$el.append "<div class='tooltip'>
        <div class='url'>URL: <span class='content'></span></div>
        <div class='ip'>IP: <span class='content'></span></div>
        <div class='service'>Service: <span class='content'></span>ms</div>
      </div>"
    @tooltip = @$el.find '.tooltip'

  draw: ->
    @svg.selectAll('rect')
      .data(@hits)
      .enter()
        .append('rect')

    @svg.selectAll('rect')
      .data(@hits)
      .attr('x', (d, i) => (i % 10) * (@size / 10))
      .attr('y', (d, i) => Math.floor(i / 10) * (@size / 10))
      .attr('width', @size / 10.5)
      .attr('height', @size / 10.5)
      .attr('class', (d) -> "status_" + d.code[0] + " status_" + d.code)

    @svg.selectAll('rect')
      .on('mouseover', @_show_tooltip)
      .on('mouseout', @_hide_tooltip)

  _show_tooltip: (d, i) =>
    @tooltip.find('.url .content').html d.host + d.path
    @tooltip.find('.ip .content').html d.ip
    @tooltip.find('.service .content').html d.service

    position = $(@svg.selectAll('rect')[0][i]).offset()
    @tooltip
      .css('top', position.top + 5)
      .css('left', position.left + 25)

    @tooltip.show()

  _hide_tooltip: =>
    @tooltip.hide()

  set_hits: (hits) ->
    @hits = _.select hits, (i) => i.host.match @regex
    @hits = @hits.slice(-100)
    @draw()

  add_hit: (hit) ->
    if hit.host.match @regex
      @hits.push hit
      @hits = @hits.slice(-100)
      @draw()
