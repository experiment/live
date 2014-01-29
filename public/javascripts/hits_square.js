(function() {
  this.HitsSquare = (function() {
    function HitsSquare(opts) {
      this.size = opts.size || 500;
      this.regex = opts.regex || /.*/;
      this.hits = [];
      this._init_d3(opts.el);
    }

    HitsSquare.prototype._init_d3 = function(el) {
      return this.svg = d3.select(el).append('svg:svg').attr('width', this.size + 'px').attr('height', this.size + 'px');
    };

    HitsSquare.prototype.draw = function() {
      var _this = this;
      this.svg.selectAll('rect').data(this.hits).enter().append('rect');
      return this.svg.selectAll('rect').data(this.hits).attr('x', function(d, i) {
        return (i % 10) * (_this.size / 10);
      }).attr('y', function(d, i) {
        return Math.floor(i / 10) * (_this.size / 10);
      }).attr('width', this.size / 10.5).attr('height', this.size / 10.5).attr('class', function(d) {
        return "status_" + d.code[0] + " status_" + d.code;
      });
    };

    HitsSquare.prototype.set_hits = function(hits) {
      var _this = this;
      this.hits = _.select(hits, function(i) {
        return i.host.match(_this.regex);
      });
      this.hits = this.hits.slice(-100);
      return this.draw();
    };

    HitsSquare.prototype.add_hit = function(hit) {
      if (hit.host.match(this.regex)) {
        this.hits.push(hit);
        this.hits = this.hits.slice(-100);
        return this.draw();
      }
    };

    return HitsSquare;

  })();

}).call(this);
