class Dashing.Korhome extends Dashing.Widget
    onData: (data) ->
        $(@node).css('background-color', @get('bg_color'))
