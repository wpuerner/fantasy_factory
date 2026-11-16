extends PanelContainer

signal closed

@export var recipe_option: OptionButton
@export var quantity_spin: SpinBox
@export var create_button: Button
@export var ticket_list_container: Container

var _table: Node2D
var _rows: Array[Dictionary] = []


func open(table: Node2D) -> void:
	_table = table
	_populate_recipes()
	_refresh_list()
	visible = true


func close() -> void:
	visible = false
	_table = null
	_rows.clear()
	_clear(ticket_list_container)
	closed.emit()


# Tickets are worked while the window is open, so keep the remaining counts live.
func _process(_delta: float) -> void:
	if visible:
		_refresh_status_labels()


func _populate_recipes() -> void:
	recipe_option.clear()
	if is_instance_valid(_table):
		for recipe: WorkbenchRecipe in _table.recipes:
			recipe_option.add_item(recipe.output_item_name)
	if recipe_option.item_count > 0:
		recipe_option.select(0)
	create_button.disabled = recipe_option.item_count == 0


func _refresh_list() -> void:
	_clear(ticket_list_container)
	_rows.clear()

	if not is_instance_valid(_table) or _table.tickets.is_empty():
		ticket_list_container.add_child(_make_message("No tickets yet. Create one below."))
		return

	for ticket: WorkbenchTicket in _table.tickets:
		ticket_list_container.add_child(_build_row(ticket))

	_refresh_status_labels()


func _refresh_status_labels() -> void:
	for entry: Dictionary in _rows:
		var ticket: WorkbenchTicket = entry["ticket"]
		var label: Label = entry["label"]
		label.text = "%s - %d remaining" % [ticket.status_text(), ticket.quantity]


func _build_row(ticket: WorkbenchTicket) -> VBoxContainer:
	var row: VBoxContainer = VBoxContainer.new()

	var top: HBoxContainer = HBoxContainer.new()

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(_make_label(ticket.output_item_name))
	info.add_child(_make_label("From %s (%d work)" % [ticket.input_item_name, ticket.work_amount]))
	top.add_child(info)

	var pause_button: Button = Button.new()
	pause_button.text = "Resume" if ticket.paused else "Pause"
	pause_button.pressed.connect(_on_pause_pressed.bind(ticket))
	top.add_child(pause_button)

	var delete_button: Button = Button.new()
	delete_button.text = "Delete"
	delete_button.pressed.connect(_on_delete_pressed.bind(ticket))
	top.add_child(delete_button)

	row.add_child(top)

	var status_label: Label = _make_label("")
	row.add_child(status_label)
	row.add_child(HSeparator.new())

	_rows.append({"ticket": ticket, "label": status_label})
	return row


func _make_label(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	return label


func _make_message(text: String) -> Label:
	var label: Label = _make_label(text)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _clear(container: Container) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _on_create_button_pressed() -> void:
	if not is_instance_valid(_table):
		return
	var index: int = recipe_option.selected
	if index < 0 or index >= _table.recipes.size():
		return

	var recipe: WorkbenchRecipe = _table.recipes[index]
	var ticket: WorkbenchTicket = WorkbenchTicket.new()
	ticket.output_item_name = recipe.output_item_name
	ticket.input_item_name = recipe.input_item_name
	ticket.work_amount = recipe.work_amount
	ticket.quantity = int(quantity_spin.value)
	_table.tickets.append(ticket)
	_refresh_list()


func _on_pause_pressed(ticket: WorkbenchTicket) -> void:
	ticket.paused = not ticket.paused
	_refresh_list()


func _on_delete_pressed(ticket: WorkbenchTicket) -> void:
	if is_instance_valid(_table):
		_table.tickets.erase(ticket)
	_refresh_list()


func _on_close_button_pressed() -> void:
	close()
