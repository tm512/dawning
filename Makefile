SRC = src

default: dawning.love

dawning.love: src/*.lua res/*
	rm -f dawning.love
	zip -j ./dawning.love $(SRC)/*
	zip -r ./dawning.love res

clean:
	rm -f dawning.love
