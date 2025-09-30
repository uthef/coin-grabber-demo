# узел элемента главного меню
class_name MenuItem extends Label

@export
var enabled: bool = true :
    set(value):
        if value:
            highlight = highlight
        else:
            modulate = Color(.3, .3, .3, 1)
        
        enabled = value
    get:
        return enabled


@export
var highlight: bool = false :
    set(value):
        
        if value and enabled:
            modulate = Color(0, .8, 1, 1)
        elif enabled:
            modulate = Color(1, 1, 1, 1)

        highlight = value
    get:
        return highlight