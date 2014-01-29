all_hits = new HitsSquare
  el: '.hits.all',
  size: 500
microryza_hits = new HitsSquare
  el: '.hits.microryza',
  size: 240,
  regex: /microryza\.com$/
experiment_hits = new HitsSquare
  el: '.hits.experiment',
  size: 240,
  regex: /experiment\.com$/

socket = io.connect();

socket.on 'hits', (hits) ->
  hits.reverse()
  all_hits.set_hits hits
  microryza_hits.set_hits hits
  experiment_hits.set_hits hits

socket.on 'hit', (hit) ->
  all_hits.add_hit hit
  microryza_hits.add_hit hit
  experiment_hits.add_hit hit

socket.on 'new_relic', (data) ->
  _.each data, (value, key) ->
    switch key
      when 'be_response_time'
        $('.backend_response_time .value').html(value + ' ms')
      when 'fe_response_time'
        $('.frontend_response_time .value').html(value.toFixed(2) + ' s')
