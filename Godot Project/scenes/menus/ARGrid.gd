extends GridContainer


export var child_ar: float = 1

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
	if get_size().x == 0 or get_size().y == 0: return
	var ar = (float(get_size().x)/float(get_size().y)) / child_ar
	columns = calc_col(get_child_count(), ar)

func _ready():
	call_deferred("update")

func _process(delta):
	call_deferred("update")
