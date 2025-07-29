import api


def main():
	gw = api.GWAPY()
	gw.initialize("Potato Sin One")
	print(gw.game_cxt.get_game_cxt())
	print(gw.game_cxt.get_world_cxt())


if __name__ == "__main__":
	main()