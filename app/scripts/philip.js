define("philip", function () {
  var states = ['AA', 'AL', 'AK', 'AS', 'AZ', 'AR', 'CA', 'CO', 'CO', 'CT', 'DE', 'DC', 'FL', 'GA', 'GU', 'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'PR', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'VI', 'WA', 'WV', 'WI', 'WY'];

  var width = 960,
      height = 500,
      centered;

  var projection = d3.geo.albersUsa()
      .scale(1070)
      .translate([width / 2, height / 2]);

  var path = d3.geo.path()
      .projection(projection);

  var svg = d3.select("body").append("svg")
      .attr("width", width)
      .attr("height", height);

  svg.append("rect")
      .attr("class", "background")
      .attr("width", width)
      .attr("height", height)
      .on("click", clicked);

  var g = svg.append("g");
  var data = null;

  d3.json('../data/disaster.json', function(error, d) {
    if (error) {
      console.log(error);
      return
    }
    data = d;
    loadTotal();
  })

  d3.json('../data/us.json', function(error, us) {
    console.log(us);
    g.append("g")
        .attr("id", "states")
      .selectAll("path")
        .data(topojson.feature(us, us.objects.states).features)
      .enter().append("path")
        .attr("d", path)
        .on("click", clicked);

    g.append("path")
        .datum(topojson.mesh(us, us.objects.states, function(a, b) { return a !== b; }))
        .attr("id", "state-borders")
        .attr("d", path);
  });

  function loadTotal() {
    output = data.disaster_labels.map(
      function (disaster) {
        return disaster + " : " + data.disasters[disaster].TOTAL
      });
    $('#data_div').html(output.join('<br>'));
  }

  function loadState(code) {
    output = Object.keys(data.disasters).map(
      function (disaster) {
        return disaster + " : " + data.states[code][disaster]
      });
    $('#data_div').html(output.join('<br>'));
  }

  function clicked(d) {
    var x, y, k;

    if (d && centered !== d) {
      var centroid = path.centroid(d);
      x = centroid[0];
      y = centroid[1];
      k = 4;
      centered = d;
    } else {
      x = width / 2;
      y = height / 2;
      k = 1;
      centered = null;
    }

    g.selectAll("path")
      .classed("active", centered && function(d) { return d === centered; });

    g.transition()
      .each('end', function () {
        console.log('You clicked on ' + states[d.id]);
        if (centered === null) {
          loadTotal();
        } else {
          loadState(states[d.id]);
        }
      })
      .duration(750)
      .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")scale(" + k + ")translate(" + -x + "," + -y + ")")
      .style("stroke-width", 1.5 / k + "px");
  }
});