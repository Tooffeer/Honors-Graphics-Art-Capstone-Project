extends Node

signal startGame

var playerNode : Node = null

var collectables = 0
var goal = 1

func setPlayerNode(node):
	playerNode = node
