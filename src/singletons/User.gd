extends Node

var levels: Dictionary = {}


func _ready():
#	if ApiService:
#		ApiService.connect("signalApiResponse", process_response)
#	ApiService.send_request(null, HTTPClient.METHOD_GET, "levels")
	process_response({})

func getLevelInfo(name: String, subLevel: int) -> LevelsInfo:
	var level = levels[name]
	return level[subLevel] as LevelsInfo

func process_response(resp):
	print("response", resp)
	var lb1 = LevelsInfo.new("1", true, "basic_1", 50)
	var lb2 = LevelsInfo.new("2", false, "basic_2", 0)
	levels["BASIC"] = [lb1, lb2]
