import api


def main():
	gw = api.GWAPY()
	gw.initialize("Dan So Lo")
	print(gw.game_cxt.get_game_cxt())
	print(gw.game_cxt.get_char_cxt())

	# print(gw.game_cxt.get_world_cxt())


if __name__ == "__main__":
	main()