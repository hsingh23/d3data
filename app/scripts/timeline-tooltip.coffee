define ["jquery", "d3", "cs!timeline-config"], ($, d3, t) ->
  class Timeline_Tooltip_Singleton
    instance = null
    class Tooltip
      format_content: (json) -> 
        @$tooltip ?= t.svg.type_symbol + t.svg.name
        tooltip = "<strong>Disaster and Type</strong>"
        for item in json
          tooltip+="<p>#{item[0]}: #{item[1]}</p>"
        @$tooltip.empty().append(tooltip)

      draw_tooltip: (content, marker_position) ->
        formated_content = @format_content(content)

    @get = ($tooltip, $marker) ->
      instance ?= new Tooltip($tooltip, $marker)
  return Timeline_Tooltip_Singleton