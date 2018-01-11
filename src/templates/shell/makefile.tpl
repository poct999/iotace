PROG = {{ program_name }}
SRC = {{ program_name }}.c

INCLUDE = {{ makefile.include }}
LIBS = {{ makefile.libs }}
CFLAGS = {{ makefile.flags }}
SOURCE = {{ makefile.source }}

all: $(PROG)

$(PROG): $(SRC)
{{'\t'}}$(CC) -o $@ $(SRC) $(SOURCE) $(LIBS) $(CFLAGS) $(INCLUDE)

clean:
{{'\t'}}rm -f $(PROG)

.PHONY: all clean