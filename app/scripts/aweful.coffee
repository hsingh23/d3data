$ ->
  margin = 
    top: 0
    right: 0
    left: 0
    bottom: 0

  width = window.innerWidth - margin.left - margin.right
  height = 200 - margin.top - margin.bottom
  x_scale = d3.time.scale().range([0, width])
  y_scale = d3.scale.log().range([height, 0]).nice()
  time_parse = d3.time.format("%Y").parse
  x_axis = d3.svg.axis().scale(x_scale).orient("bottom").tickSize(-height).tickSubdivide(true)
  y_axis = d3.svg.axis().scale(y_scale).orient("left").ticks(20, d3.format(",.1s")).tickSize(6, 0)

  boss_line = d3.svg.line().x((data) -> x_scale data.time).y((data) -> y_scale data.value)
  click = ()-> console.log "yo" 
  svg = d3.select(".boss_chart")
    .append("svg")
      .attr("class", "cost-slider")
      .attr("width",width + margin.right + margin.left)
      .attr("height",height + margin.top + margin.bottom)
    .append("g")
      .attr("transform":"translate(#{margin.left}, #{margin.top})")
      .on("click", click)


  d3.json "./data/emdat-by-time.json", (error, data) ->
    window.damages_summary_data = []
    for year, list_of_disasters of data
      t = "year":time_parse year
      for interesting in ["num_disasters","num_killed","num_injured","num_affected","num_homeless","total_affected","total_damage"]
        t[interesting] =  d3.sum list_of_disasters, (d) -> d[interesting]
      damages_summary_data.push(t)
    damages_summary_data.get_classified = (type) -> $.map @, (v) -> v[type]

    x_scale.domain d3.extent damages_summary_data.get_classified "year"
    y_scale.domain [1, d3.max damages_summary_data.get_classified "total_damage"]
    window.x_scale = x_scale
    window.y_scale = y_scale
    total_damage_area = d3.svg.area()
      .x((d) -> x_scale d.year)
      .y0(height)
      .y1((d) -> y_scale d.total_damage)
      .interpolate("monotone")
    total_damage_line = d3.svg.line()
      .x((d) -> x_scale d.year)
      .y((d) -> y_scale d.total_damage)
      .interpolate("monotone")

    svg.append("clipPath")
        .attr("id", "clip")
      .append("rect")
        .attr("width", width)
        .attr("height", height)

    svg.append("path")
      .attr("class", "area")
      .attr("clip-path", "url(#clip)")
      .attr("d", total_damage_area(damages_summary_data))

    svg.append("path")
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", total_damage_line(damages_summary_data))

    svg.append("g")
      .attr("class", "y axis")
      .call(y_axis)

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0, #{height})")
      .call(x_axis)

