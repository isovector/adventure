OBJDIR = obj

vpath %.h libs/poly2tri
vpath %.cc libs/poly2tri/common
vpath %.h libs/poly2tri/common
vpath %.cc libs/poly2tri/sweep
vpath %.h libs/poly2tri/sweep

objects = $(addprefix $(OBJDIR)/, adventure.o drawing.o input.o lua.o path.o shapes.o advancing_front.o cdt.o sweep.o sweep_context.o)

all : objdir $(objects) $(poly2tri)
	g++ -o adventure -lSDL -lSDL_image -lSDL_gfx -lSDL_ttf -lpthread -lm -llua $(objects) $(poly2tri)

profile :  objdir $(objects) $(poly2tri)
	g++ -pg -o adventure -lSDL -lSDL_image -lSDL_gfx -lSDL_ttf -lpthread -lm -llua $(objects) $(poly2tri)

objdir : $(OBJDIR)

$(OBJDIR) : 
	mkdir $(OBJDIR)

$(OBJDIR)/%.o : %.cc adventure.h drawing.h input.h lua.h path.h poly2tri.h shapes.h utils.h advancing_front.h cdt.h sweep.h sweep_context.h
	g++ -g -c $< -o $@

.PHONY : clean
clean : 
	rm adventure $(objects)
	rmdir $(OBJDIR)
