define ["jquery", "d3", "cs!timeline-config"], ($, d3, t) ->
  class Timeline_Singleton
    instance = null
    @get = () ->
      instance ?= new Timeline(t)
    class Timeline
      constructor: (t) ->
        @$timeline_container = $ "##{t.timeline_container_id}"
        @$svg = $ "##{t.svg}"
        @$data_views_select = $('<select id="type" name="type">').appendTo(@$timeline_container)

        @width = t.timeline_width
        @height = t.timeline_height
        @svg = d3.select(@$timeline_container)
          .attr("id", "#{t.svg_id}")
          .append("svg")
            .attr("width",@width)
            .attr("height",@height)
        @timeline = @svg.append("g")
          .attr("id", "#{t.timeline_slider_id}")
        @x_scale = d3.time.scale().range([0, @width])
        @y_scale = d3.scale.log().range([@height, 0]).nice()
        @set_data_views()
        @register_events()
        @load_emdat_data()

      get_year_data: (pageX) ->
        @reverse_x_scale(pageX).getFullYear()

      get_tooltip_content: (year) ->
        ( [disaster["disaster_type"],disaster[@type]] for disaster in @data[year] )

      set_data_views: ()->
        # TODO - bad#5 - Staticly set data_views, should get from data
        @data_views = ["num_disasters","num_killed","num_injured","num_affected","num_homeless","total_affected","total_damage"]
        for x in @data_views
          @$data_views_select.append $("<option>").attr('value',x).text(x)

      register_events: ()->
        @$data_views_select.on "change", () => @redraw @$data_views_select.val()
        $(window).resize _.debounce((() => @redraw @$data_views_select.val()), 250)
        @$svg.on "mousemove", (e) => 
          @$xmarker.css "left", e.pageX
          @$tooltip.css "left", e.pageX
        @$svg.mousemove _.debounce(((e) => @format_tooltip(@get_tooltip_content (@get_year_data e.pageX))), 250)

      animate: (selector, maker, enter_class) ->
        # update
        selector
          .transition()
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
        @x_scale.domain d3.extent @damages_summary_data.get_classified_array "year"
        @x_scale.range([0, window.innerWidth])
        @reverse_x_scale = @x_scale.invert 
        @y_scale.domain [1, d3.max @damages_summary_data.get_classified_array @type]
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
            for interesting in @data_views
              t[interesting] =  d3.sum list_of_disasters, (d) -> d[interesting]
            @damages_summary_data.push(t)
          @damages_summary_data.get_classified_array = (type) -> $.map @, (v) -> v[type]

          @redraw("total_damage")

  window.my_timeline = new Timeline("#timeline", window.innerWidth, 100)
