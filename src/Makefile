# this is a comment
SRC=mvkernel.asm strctrs.asm strcvtf.asm strcpsup.asm strmtds.asm
COBJ=$(SRC:.cpp=.o) # replaces the .cpp from SRC with .o
OBJ=$(COBJ:.asm=.o) # replaces the .asm from SRC with .o
EXE=strings.dll
RES=$(EXE:.dll=.res)
DEF=$(EXE:.dll=.def)
#LIB=import32.lib cw32i.lib

#AS=nasm
AS=tasm32
#CC=gcc
CC=bcc32
#LINK=ld
LINK=ilink32
#AFLAGS=-f coff -O2
#AFLAGS=-E test.err -f obj -O2 -g -F borland
AFLAGS = /la /ml /c /m25
#CFLAGS=-Wall #gcc flags
#CFLAGS=-tW -tWM- -Od -Hc -Vx -Ve -X- -r- -a8 -k -y -v -vi- -c #std bcc32 flags
CFLAGS=-c
#OFLAGS=-O3
OFLAGS=-b- -d -O1 -r
LLFLAGS=-m -M -s    #Link loggings flags with ilink32
#LFLAGS=-mi386pe    #Link flags with gcc
LFLAGS = -c -Tpd -aa -x -Gn -Gi -v -b:0x340000 #Link flags with ilink32
RM=rm

# combined w/ next line will compile recently changed .asm files
%.o: %.asm
	$(AS) $(AFLAGS) $< $@ $(<:.asm=.lst)
#	 $(AS) $(AFLAGS) -l $(<:.asm=.lst) -o $@ $<

%.o: %.cpp
	$(CC) $(CFLAGS) $(OFLAGS) -o $@ $<

.PHONY : all	 # .PHONY ignores files named all
all: $(EXE)	 # all is dependent on $(EXE) to be complete

$(EXE): $(OBJ) $(DEF) $(RES) # $(EXE) is dependent on all of the files in $(OBJ) to exist
#	 $(LINK) $(OBJ) $(LIB) $(LFLAGS) -o $@
#	 $(LINK)  $(LFLAGS) $(LLFLAGS) c0w32.obj $(OBJ),$@,, $(LIB), $(DEF), $(RES)
	$(LINK)  $(LFLAGS) $(LLFLAGS) $(OBJ) ,$@,, $(LIB), $(DEF), $(RES)

.PHONY : clean	 # .PHONY ignores files named clean
clean:
	-$(RM) -f $(OBJ) *.lst	  # '-' causes errors not to exit the process