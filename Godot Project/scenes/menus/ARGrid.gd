extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var child_ar: float

func calc_col(n, ar):
	# find a col that minimizes min(1/col, ar/ceil(n/col)), allowing for maximal content size
	if n == 0 : return 1
	
	var lig1 = int(ceil(n/floor(sqrt(n*ar))))
	var col1 = int(ceil(n/lig1))

	var lig2 = lig1-1 if lig1 > 1 else 1
	var col2 = int(ceil(n/lig2))

	if ceil(n/col1)*ar <= col2: return col1
	else: return col2

func update():
	if get_size().x == 0 : return
	var ar = (get_size().x/get_size().y) / child_ar
	columns = calc_col(get_child_count(), ar)

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("update")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	call_deferred("update")
