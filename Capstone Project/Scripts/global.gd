extends Node

signal startGame
signal gameOver

var playerNode : Node = null

var collectables = 0
var goal = 4

func setPlayerNode(node):
	playerNode = node
