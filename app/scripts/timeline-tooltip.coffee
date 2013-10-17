exports = this
return require ["jquery", "d3"], ($, d3) ->
  console.log $
  return "1"
  # class Timeline_Tooltip_Singleton
  #   instance = null
  #   class Tooltip
  #     constructor: ($tooltip, $marker) ->
  #       @$tooltip = @$tooltip || $tooltip || $(".marker")
  #       @$marker = @$marker || $marker || $(".marker")
  #       @timeline = @svg.append("g")
  #         .attr("id", "timeline-slider")

  #     format_content: (json) -> 
  #       tooltip = "<strong>Disaster and #{@type}</strong>"
  #       for item in json
  #         tooltip+="<p>#{item[0]}: #{item[1]}</p>"
  #       @$tooltip.empty().append(tooltip)

  #     draw_tooltip: (content, marker_position) ->
  #       formated_content = @format_content(content)

  #   @get = ($tooltip, $marker) ->
  #     instance ?= new Tooltip($tooltip, $marker)
  # return Timeline_Tooltip_Singleton