margin = 
  top: 20
  right: 20
  left: 50
  bottom: 30

width = 500 - margin.left - margin.right
height = 500 - margin.top - margin.bottom
x_scale = d3.time.scale().range([0, width])
y_scale = d3.scale.log().range([height, 0])

x_axis = d3.svg.axis().scale(x_scale).orient("bottom").ticks(5)
y_axis = d3.svg.axis().scale(y_scale).orient("left").ticks(5)

boss_line = d3.svg.line().x((data) -> x_scale data.time).y((data) -> y_scale data.value)
svg = d3.select(".boss_chart")
  .append("svg")
    .attr("width",width + margin.right + margin.left)
    .attr("width",width + margin.right + margin.left)
  .append("g")
    .attr("transform":"translate(#{margin.top}, #{margin.right})")

d3.json "./data/emdat-by-time.json", (error, data) ->
  window.damages_summary_data = []
  for year, list_of_disasters of data
    t = "year":year
    for interesting in ["num_disasters","num_killed","num_injured","num_affected","num_homeless","total_affected","total_damage"]
      t[interesting] =  d3.sum list_of_disasters, (d) -> d[interesting]
    damages_summary_data.push(t)
  damages_summary_data.get_classified = (type) -> $.map @, (v) -> v[type]

  x_scale.domain d3.extent damages_summary_data.get_classified "year"
  y_scale.domain [0.00001, d3.max damages_summary_data.get_classified "total_damage"]
  window.x_scale = x_scale
  window.y_scale = y_scale
  total_damage_line = d3.svg.line()
    .x((d) -> x_scale d.year).y((d) -> y_scale d.total_damage)
  svg.append("path")
    .attr("class", "path")
    .attr("d", total_damage_line(damages_summary_data));



# d3.tsv("data/data.tsv", function(error, data) {
# data.forEach(function(d) {
# d.date = parseDate(d.date);
# d.close = +d.close;
# });
# // Scale the range of the data
# x.domain(d3.extent(data, function(d) { return d.date; }));
# y.domain([0, d3.max(data, function(d) { return d.close; })]);
# svg.append("path") // Add the valueline path.
# .attr("class", "line")
# .attr("d", valueline(data));
# svg.append("g") // Add the X Axis
# .attr("class", "x axis")
# .attr("transform", "translate(0," + height + ")")
# .call(xAxis);Starting with a basic graph 20
# svg.append("g") // Add the Y Axis
# .attr("class", "y axis")
# .call(yAxis);
# });