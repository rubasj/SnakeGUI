extends Node

@export var snake_scene : PackedScene

#game variables
var score : int
var game_started : bool = false
var def_body_length : int = 3

#grid variables
var cell_size : int = 50
var cells : int = 20

#berry variables
var berry_pos : Vector2
var regen_berry : bool = true
"res://Scene/snake_segment.tscn"

#snake variables
var old_data : Array
var snake_data : Array
var snake : Array

#movement variables
var center = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction : Vector2
var can_move: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	newGame()
	
func newGame():
	move_direction = up
	score = 0
	can_move = true
	initGameBoard()
	initSnake()
	spawnBerry()

func initGameBoard():
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	$GameOverMenu.hide()
	$Hud.get_node("ScorePanel/ScoreLabel").text = "SCORE: " + str(score)
	
func initSnake():
	clearSnake()
	#starting with the start_pos, create tail segments vertically down
	for i in range(def_body_length):
		addSegment(center + Vector2(0, i))

func clearSnake():
	if len(snake) > 0:
		removeAllSegments()
		old_data.clear()
		snake_data.clear()

func removeAllSegments():
	for segment in snake:
		segment.queue_free()
	snake.clear()
	snake_data.clear()
	
func addSegment(pos):
	snake_data.append(pos)
	var snakeSegment = snake_scene.instantiate()
	snakeSegment.position = scalePosition(pos)
	add_child(snakeSegment)
	snake.append(snakeSegment)

func scalePosition(pos):
	return (pos * cell_size) + Vector2(0, cell_size)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	updateSnakePosition()

#update movement from keypresses	
func updateSnakePosition():
	if can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			isGameStarted()
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			isGameStarted()
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			isGameStarted()
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			isGameStarted()

func isGameStarted():
	can_move = false
	if not game_started:
		startGame()

func startGame():
	game_started = true
	$MoveTimer.start()

func onTimerTimeout():
	#allow snake movement
	can_move = true
	updatePosition()
	isSnakeOutOfBounds()
	isBodyInCollision()
	isFoodEaten()
	
func updatePosition():
	#use the snake's previous position to move the segments
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		#move all the segments along by one
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = scalePosition(snake_data[i])
	
func isSnakeOutOfBounds():
	if snake_data[0].x < 0 or snake_data[0].x > cells - 1 or snake_data[0].y < 0 or snake_data[0].y > cells - 1:
		endGame()
		
func isBodyInCollision():
	for i in range(1, len(snake_data)):
		if snake_data[0] == snake_data[i]:
			endGame()
			
func isFoodEaten():
	if snake_data[0] == berry_pos:
		score += 1
		$Hud.get_node("ScorePanel/ScoreLabel").text = "SCORE: " + str(score)
		addSegment(old_data[-1])
		spawnBerry()
	
func spawnBerry():
	generateRandomPosition()
	$Food.position = scalePosition(berry_pos)
	regen_berry = true

func generateRandomPosition():
	while regen_berry:
		regen_berry = false
		berry_pos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
		isBerryOutOfSnake()
	
func isBerryOutOfSnake():
	for i in snake_data:
			if berry_pos == i:
				regen_berry = true
	
func endGame():
	$GameOverMenu.show()
	$MoveTimer.stop()
	game_started = false
	get_tree().paused = true


func _on_game_over_menu_restart():
	newGame()
