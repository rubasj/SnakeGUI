extends Node

@export var snake_Scene : PackedScene
#game variables
var score : int
var snakeLength : int = 5
var gameOver : bool = false

#grid variables 
var cells : int = 20
var cellSize : int = 50

# snake variables
var snakeBody : Array

# movement variables
# center (start position)
var center = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var currMoveDirection = up
var can_move : bool

# food variables
var berryPos : Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	newGame()


func newGame():
	score = 0
	snakeLength = 3
	$hud.get_node("ScoreLabel").text = "Score: " + str(score)
	can_move = true
	initSnake()
	moveSpawnBerry()
	#gameLoop()


func initSnake():
	snakeBody.clear()
	
	for i in range(score): 
		addSegment(center + Vector2(0, i))
		
	

func addSegment(pos):
	var segment = snake_Scene.instantiate()
	segment.position = (pos * cellSize) + Vector2(0, cellSize)
	add_child(segment)
	snakeBody.append(segment)

func handleInput():
	if can_move:
		
		if Input.is_action_just_pressed("move_down") and currMoveDirection != up:
			currMoveDirection = down
			can_move = false
		if Input.is_action_just_pressed("move_up") and currMoveDirection != down:
			currMoveDirection = up
			can_move = false
		if Input.is_action_just_pressed("move_right") and currMoveDirection != left:
			currMoveDirection = right
			can_move = false
		if Input.is_action_just_pressed("move_left") and currMoveDirection != right:
			currMoveDirection = left
			can_move = false

func checkGameStatus():
	checkOutOfBounds()
	checkBodyCollision()
	
func checkOutOfBounds():
	if snakeBody[0].x < 0 or snakeBody[0].x > cells - 1 or snakeBody[0].y < 0 or snakeBody[0].y > cells - 1:
		end_game()

func checkBodyCollision():
	for i in range(1, len(snakeBody)):
		if snakeBody[0] == snakeBody[i]:
			end_game()

func checkBerryStatus():
	if snakeBody[0] == berryPos:
		score =+ 1
		snakeLength =+ 1
		$Hud.get_node("ScoreLabel").text = "SCORE: " + str(score)
		addSegment(snakeBody[-1])
		moveSpawnBerry()
		
func moveSpawnBerry():
	berryPos = Vector2(randi_range(0, cells - 1), randi_range(0, cells - 1))
	
	

#func gameLoop():
	
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
