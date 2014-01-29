class @HitsSquare
  constructor: (opts) ->
    @size = opts.size || 500;
    @hits = []
    @_init_d3(opts.el)

  _init_d3: (el) ->
    @svg = d3.select(el)
      .append('svg:svg')
      .attr('width', @size + 'px')
      .attr('height', @size + 'px')

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

  set_hits: (hits) ->
    @hits = hits
    @hits = @hits.slice(-100)
    @draw()

  add_hit: (hit) ->
    @hits.push hit
    @hits = @hits.slice(-100)
    @draw()
