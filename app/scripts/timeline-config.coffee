define ["cs!selector"], (sel) ->
  timeline = 
    svg: sel("#timeline-slider-svg")
    timeline_container: sel("#timeline")
    timeline_slider: sel("#timeline-slider")
    tooltip: sel("#tooltip")
    marker: sel(".marker")
    timeline_width: window.innerWidth
    timeline_height: 100