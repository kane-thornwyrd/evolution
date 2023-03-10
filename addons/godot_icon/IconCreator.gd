@tool
extends ConfirmationDialog

const CreateIconScript := preload("res://addons/godot_icon/CreateIcon.gd")
const HELP := "Please choose single file for your icon or six images with sizes:\n16x16, 32x32, 48x48, 64x64, 128x128 and 256x256."

var create_icon := CreateIconScript.new()
var image_paths := PackedStringArray()
var images: Array


func _ready() -> void:
	create_icon.error_callable = print_error
	$Buttons/ChooseImages.pressed.connect($ChooseImagesDialog.popup_centered)
	$ChooseImagesDialog.files_selected.connect(on_images_selected)
	$Buttons/ChooseIcon.pressed.connect($ChooseIconDialog.popup_centered)
	$ChooseIconDialog.file_selected.connect(on_icon_path_selected)
	$Buttons/Errors.text = HELP
	confirmed.connect(on_confirmed)
	disable_ok()


func on_confirmed() -> void:
	create_icon.save_icon($ChooseIconDialog.current_path, images)


func on_icon_path_selected(icon_path: String) -> void:
	$Buttons/ChooseIcon.text = icon_path
	disable_ok()


func on_images_selected(paths: Array) -> void:
	$Buttons/ChooseImages.text = "Choose image(s)"
	$Buttons/Errors.text = ""
	remove_all_children($Buttons/Images)
	images = []
	match paths.size():
		1:
			images = create_icon.prepare_images(paths[0])
		6:
			images = create_icon.load_images(paths)
		_:
			$Buttons/Errors.text = HELP
	for image in images:
		var texture_rect = create_texture_rect(image)
		$Buttons/Images.add_child.call_deferred(texture_rect)
		print(texture_rect.texture.get_size(), texture_rect.get_minimum_size())
	disable_ok()


func create_texture_rect(image: Image) -> TextureRect:
	var texture := ImageTexture.create_from_image(image)
	var texture_rect := TextureRect.new()
	texture_rect.texture = texture
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
	return texture_rect


func disable_ok() -> void:
	get_ok_button().disabled = $ChooseIconDialog.current_file == "" or images.size() != 1 and images.size() != 6


func print_error(error_message) -> void:
	$Buttons/Errors.text += str(error_message, "\n")


func remove_all_children(parent: Node) -> void:
	while parent.get_child_count():
		parent.remove_child(parent.get_child(0))
