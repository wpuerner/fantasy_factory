class_name MessageResource extends Resource

signal message_published(message_text: String)

func publish(message_text: String):
	message_published.emit(message_text)
	
