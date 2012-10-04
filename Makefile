SRC = src

default: october.love

october.love: src/*.lua
	rm -f october.love
	zip -j ./october.love $(SRC)/*
	zip -r ./october.love res

clean:
	rm -f october.love
