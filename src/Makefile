# Makefile simples para compilar .mli -> .cmi e .ml -> .cmo e gerar o executável

.PHONY: all clean native

OCAMLC = ocamlc
OCAMLOPT = ocamlopt
FLAGS =

SOURCES = types.ml tabuleiro.ml barco.ml protocolo.ml estrategia.ml main.ml
INTERFACES = types.mli tabuleiro.mli barco.mli protocolo.mli estrategia.mli main.mli
OBJECTS = $(SOURCES:.ml=.cmo)
NATIVE_OBJECTS = $(SOURCES:.ml=.cmx)
TARGET = batalha_naval
TARGET_NATIVE = batalha_naval.native

all: $(TARGET)

$(TARGET): $(INTERFACES:.mli=.cmi) $(OBJECTS)
	$(OCAMLC) $(FLAGS) -o $@ $(OBJECTS)

%.cmi: %.mli
	$(OCAMLC) $(FLAGS) -c $<

%.cmo: %.ml %.cmi
	$(OCAMLC) $(FLAGS) -c $<

clean:
	rm -f *.cmi *.cmo $(TARGET) $(TARGET_NATIVE)
