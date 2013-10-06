moduleKeywords = ['extended', 'included']
class Module
  @extend: (obj) ->
    for key, value of obj when key not in moduleKeywords
      @[key] = value

    obj.extended?.apply(@)
    this

  @include: (obj) ->
    for key, value of obj when key not in moduleKeywords
      # Assign properties to the prototype
      @::[key] = value

    obj.included?.apply(@)
    this

class Timeline extends Module
  constructor: (@$selector, @width, @height) ->
    @svg = d3.select(@$selector)
      .attr("id", "timeline-slider-svg")
      .append("svg")
        .attr("width",@width)
        .attr("height",@height)

    @timeline = @svg.append("g")
      .attr("id", "timeline-slider")
    @x_scale = d3.time.scale().range([0, @width])
    @y_scale = d3.scale.log().range([@height, 0]).nice()
    @$types = $('<select id="type" name="type">').appendTo('#timeline')
    @set_options()
    @register_events()
    @load_emdat_data()

  get_x_data: (screen_x, screen_y) ->
    console.log screen_x, screen_y

  set_options: ()->
    @types = ["num_disasters","num_killed","num_injured","num_affected","num_homeless","total_affected","total_damage"]
    for x in @types
      @$types.append $("<option>").attr('value',x).text(x)

  register_events: ()->
    @$types.on "change", () => @redraw @$types.val()
    $(window).resize _.debounce((() => @redraw @$types.val()), 500)

  animate: (selector, maker, enter_class) ->
    # update
    selector
      .transition()
        .duration(400)
        .ease("linear")
        .attr("d", (d) => maker d)

    # insert
    selector.enter()
      .append("path")
      .attr("class", enter_class)
      .attr("d", (d) => maker d)

    # remove
    selector.exit()
      .transition()
      .remove()
    
  redraw: (@type = @type) ->
    console.log "Called redraw with #{@type}"
    @svg.attr "width", window.innerWidth 
    @x_scale.domain d3.extent @damages_summary_data.get_classified "year"
    @x_scale.range([0, window.innerWidth])
    @y_scale.domain [1, d3.max @damages_summary_data.get_classified @type]
    @total_type_area_maker = d3.svg.area()
      .x((d) => @x_scale d.year)
      .y0(@height)
      .y1((d) => @y_scale d[@type])
      .interpolate("monotone")

    @total_type_line_maker = d3.svg.line()
      .x((d) => @x_scale d.year)
      .y((d) => @y_scale d[@type])
      .interpolate("monotone")

    timeline_area = @timeline.selectAll("#timeline-slider > .area").data([@damages_summary_data])

    timeline_line = @timeline.selectAll("#timeline-slider > .line").data([@damages_summary_data])

    @animate timeline_area, @total_type_area_maker, "area"
    @animate timeline_line, @total_type_line_maker, "line"


  load_emdat_data: () ->
    @time_parse = d3.time.format("%Y").parse
    d3.json "./data/emdat-by-time.json", (error, data) =>
      @data = data
      if error
        console.log error
        return
      @damages_summary_data = []
      for year, list_of_disasters of data
        t = "year":@time_parse year
        for interesting in @types
          t[interesting] =  d3.sum list_of_disasters, (d) -> d[interesting]
        @damages_summary_data.push(t)
      @damages_summary_data.get_classified = (type) -> $.map @, (v) -> v[type]
      @redraw("total_damage")

window.my_timeline = new Timeline("#timeline", window.innerWidth, 100)