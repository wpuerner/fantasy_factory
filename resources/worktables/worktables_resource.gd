extends Resource

var enchanting_tables: Array[Node2D]

func register_enchanting_table(table):
	enchanting_tables.append(table)

func get_enchanting_tables():
	return enchanting_tables
