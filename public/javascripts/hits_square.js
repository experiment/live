(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.HitsSquare = (function() {
    function HitsSquare(opts) {
      this._hide_tooltip = __bind(this._hide_tooltip, this);
      this._show_tooltip = __bind(this._show_tooltip, this);
      this.size = opts.size || 500;
      this.regex = opts.regex || /.*/;
      this.hits = [];
      this.$el = $(opts.el);
      this._init(opts.el);
    }

    HitsSquare.prototype._init = function(el) {
      this.svg = d3.select(el).append('svg:svg').attr('width', this.size + 'px').attr('height', this.size + 'px');
      this.$el.append("<div class='tooltip'></div>");
      return this.tooltip = this.$el.find('.tooltip');
    };

    HitsSquare.prototype.draw = function() {
      var _this = this;
      this.svg.selectAll('rect').data(this.hits).enter().append('rect');
      this.svg.selectAll('rect').data(this.hits).attr('x', function(d, i) {
        return (i % 10) * (_this.size / 10);
      }).attr('y', function(d, i) {
        return Math.floor(i / 10) * (_this.size / 10);
      }).attr('width', this.size / 10.5).attr('height', this.size / 10.5).attr('class', function(d) {
        return "status_" + d.code[0] + " status_" + d.code;
      });
      return this.svg.selectAll('rect').on('mouseover', this._show_tooltip).on('mouseout', this._hide_tooltip);
    };

    HitsSquare.prototype._show_tooltip = function(d, i) {
      var content, position;
      content = d.host + d.path;
      this.tooltip.html(content);
      position = $(this.svg.selectAll('rect')[0][i]).offset();
      this.tooltip.css('top', position.top + 5).css('left', position.left + 25);
      return this.tooltip.show();
    };

    HitsSquare.prototype._hide_tooltip = function() {
      return this.tooltip.hide();
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
