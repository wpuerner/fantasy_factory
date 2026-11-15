extends PanelContainer

signal closed

@export var contracts_resource: ContractsResource
@export var active_list_container: Container
@export var available_list_container: Container
@export var available_section: Control
@export var toggle_available_button: Button

var _active_rows: Array[Dictionary] = []


func open() -> void:
	available_section.visible = false
	toggle_available_button.text = "Show Available Contracts"
	if not contracts_resource.contracts_changed.is_connected(_on_contracts_changed):
		contracts_resource.contracts_changed.connect(_on_contracts_changed)
	_refresh()
	visible = true


func close() -> void:
	if contracts_resource.contracts_changed.is_connected(_on_contracts_changed):
		contracts_resource.contracts_changed.disconnect(_on_contracts_changed)
	visible = false
	_clear(active_list_container)
	_clear(available_list_container)
	closed.emit()


# The window stays open while the world runs, so the "can I fulfill this?"
# state has to be re-evaluated as items move around.
func _process(_delta: float) -> void:
	if visible:
		_refresh_progress()


func _on_contracts_changed() -> void:
	if visible:
		_refresh()


func _refresh() -> void:
	_clear(active_list_container)
	_clear(available_list_container)
	_active_rows.clear()

	if contracts_resource.active_contracts.is_empty():
		active_list_container.add_child(_make_message("No active contracts. Accept one below."))
	else:
		for contract: Contract in contracts_resource.active_contracts:
			active_list_container.add_child(_build_active_row(contract))

	if contracts_resource.available_contracts.is_empty():
		available_list_container.add_child(_make_message("No contracts available right now."))
	else:
		for contract: Contract in contracts_resource.available_contracts:
			available_list_container.add_child(_build_available_row(contract))

	_refresh_progress()


func _refresh_progress() -> void:
	var counts: Dictionary = contracts_resource.count_items_in_game_space()
	for entry: Dictionary in _active_rows:
		var contract: Contract = entry["contract"]
		var fulfill_button: Button = entry["button"]
		var progress_label: Label = entry["label"]
		fulfill_button.disabled = not contracts_resource.can_fulfill_with(counts, contract)
		progress_label.text = _progress_text(counts, contract)


func _build_active_row(contract: Contract) -> VBoxContainer:
	var row: VBoxContainer = VBoxContainer.new()

	var top: HBoxContainer = HBoxContainer.new()

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(_make_label(contract.contract_name))
	info.add_child(_make_label(contract.describe_items()))
	top.add_child(info)

	var fulfill_button: Button = Button.new()
	fulfill_button.text = "Fulfill ($%s)" % _format_money(contract.reward)
	fulfill_button.pressed.connect(_on_fulfill_pressed.bind(contract))
	top.add_child(fulfill_button)
	row.add_child(top)

	var progress_label: Label = _make_label("")
	row.add_child(progress_label)
	row.add_child(HSeparator.new())

	_active_rows.append({"contract": contract, "button": fulfill_button, "label": progress_label})
	return row


func _build_available_row(contract: Contract) -> VBoxContainer:
	var row: VBoxContainer = VBoxContainer.new()

	var top: HBoxContainer = HBoxContainer.new()

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_child(_make_label(contract.contract_name))
	info.add_child(_make_label(contract.describe_items()))
	top.add_child(info)

	var accept_button: Button = Button.new()
	accept_button.text = "Accept"
	accept_button.pressed.connect(_on_accept_pressed.bind(contract))
	top.add_child(accept_button)
	row.add_child(top)

	row.add_child(_make_label("Reward: $%s" % _format_money(contract.reward)))
	row.add_child(HSeparator.new())
	return row


func _progress_text(counts: Dictionary, contract: Contract) -> String:
	var parts: Array[String] = []
	for item_name in contract.items.keys():
		parts.append("%s %d/%d" % [item_name, int(counts.get(item_name, 0)), contract.get_required_quantity(item_name)])
	return "Have: " + ", ".join(parts)


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


func _format_money(amount: float) -> String:
	return str(snappedf(amount, 0.01))


func _on_accept_pressed(contract: Contract) -> void:
	contracts_resource.accept(contract)


func _on_fulfill_pressed(contract: Contract) -> void:
	contracts_resource.fulfill(contract)


func _on_toggle_available_button_pressed() -> void:
	available_section.visible = not available_section.visible
	if available_section.visible:
		toggle_available_button.text = "Hide Available Contracts"
	else:
		toggle_available_button.text = "Show Available Contracts"


func _on_close_button_pressed() -> void:
	close()
