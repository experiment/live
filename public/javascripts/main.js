(function() {
  var all_hits, experiment_hits, microryza_hits, socket;

  all_hits = new HitsSquare({
    el: '.hits.all',
    size: 500
  });

  microryza_hits = new HitsSquare({
    el: '.hits.microryza',
    size: 240,
    regex: /microryza\.com$/
  });

  experiment_hits = new HitsSquare({
    el: '.hits.experiment',
    size: 240,
    regex: /experiment\.com$/
  });

  socket = io.connect();

  socket.on('hits', function(hits) {
    hits.reverse();
    all_hits.set_hits(hits);
    microryza_hits.set_hits(hits);
    return experiment_hits.set_hits(hits);
  });

  socket.on('hit', function(hit) {
    all_hits.add_hit(hit);
    microryza_hits.add_hit(hit);
    return experiment_hits.add_hit(hit);
  });

  socket.on('new_relic', function(data) {
    return _.each(data, function(value, key) {
      switch (key) {
        case 'be_response_time':
          return $('.backend_response_time .value').html(value + ' ms');
        case 'fe_response_time':
          return $('.frontend_response_time .value').html(value.toFixed(2) + ' s');
      }
    });
  });

}).call(this);
