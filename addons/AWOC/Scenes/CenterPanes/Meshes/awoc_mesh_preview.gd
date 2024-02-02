@tool
extends ColorRect

@export var main_camera: Camera3D
@export var subject: Node3D


var direction: Vector3  = Vector3.ZERO
var rotate: int = 0
var move_speed: int = 5
var zoom_speed: int = 10
var rotate_speed: int = 3
var camera_position: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_position = main_camera.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if direction != Vector3.ZERO:
		var new_position: Vector3 = main_camera.position
		if direction.x > 0:
			new_position.x = main_camera.position.x + (move_speed * delta)
		elif  direction.x < 0:
			new_position.x = main_camera.position.x - (move_speed * delta)
		if direction.y > 0:
			new_position.y = main_camera.position.y + (move_speed * delta)
		elif direction.y < 0:
			new_position.y = main_camera.position.y - (move_speed * delta)
		if direction.z > 0:
			new_position.z = main_camera.position.z + (zoom_speed * delta)
		elif direction.z < 0:
			new_position.z = main_camera.position.z - (zoom_speed * delta)
		main_camera.position = new_position;
		
	if rotate > 0:
		subject.rotate_y(rotate_speed * delta)
	elif rotate < 0:
		subject.rotate_y(-rotate_speed * delta)
	
func on_button_up():
	direction = Vector3.ZERO
	rotate = 0
	
func _on_rotate_left_button_button_down():
	rotate = -1

func _on_up_button_button_down():
	direction.y = -1

func _on_rotate_right_button_button_down():
	rotate = 1

func _on_left_button_button_down():
	direction.x = 1

func _on_right_button_button_down():
	direction.x = -1

func _on_zoom_out_button_button_down():
	direction.z = 1

func _on_down_button_button_down():
	direction.y = 1

func _on_zoom_in_button_button_down():
	direction.z = -1

func _on_reset_button_pressed():
	main_camera.position = camera_position
	subject.rotation = Vector3.ZERO

func _on_move_speed_h_slider_value_changed(value):
	move_speed = value

func _on_rotate_speed_h_slider_value_changed(value):
	rotate_speed = value

func _on_zoom_speed_h_slider_value_changed(value):
	zoom_speed = value
	
"""namespace AWOC
{
	[Tool]
	public partial class MeshPreview : BasePreviewPane
	{
		[Export] SubViewport viewport;
		[Export] Camera3D camera;

		Node3D subject;

		Vector3 direction = Vector3.Zero;
		int rotate = 0;
		int moveSpeed = 5;
		int zoomSpeed = 10;
		int rotateSpeed = 3;
		Vector3 cameraPosition;

		void FreeSubject()
		{
			if(subject != null)
			{
				subject.QueueFree();
				subject = null;
			}
		}

		public void SetNewSubject(Node3D newSubject)
		{
			FreeSubject();
			subject = newSubject;
			viewport.AddChild(subject);
		}

		public override void _Ready()
		{
			cameraPosition = camera.Position;
		}
		
		public override void _Process(double delta)
		{
			
		}

		

		void _on_center_pressed()
		{
			camera.Position = cameraPosition;
			subject.Rotation = Vector3.Zero;
		}
	}
}"""








