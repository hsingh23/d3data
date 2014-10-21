define [], () ->
  class Selector
    constructor: (@str) ->
      @valid = true
      @type_symbol = @str[0]
      if @type_symbol is "."
        @type_name = "class"
      else if @type_symbol is "#"
        @type_name = "id"
      else
        @valid = false
      @name = @str.slice 1

