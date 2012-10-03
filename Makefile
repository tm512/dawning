SRC = src

default: october.love

october.love: src/*.lua
	rm -f october.love
	zip -j ./october.love $(SRC)/*

clean:
	rm -f october.love
