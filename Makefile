OBJDIR=obj
vpath %.h libs/poly2tri
vpath %.cc libs/poly2tri/common
vpath %.h libs/poly2tri/common
vpath %.cc libs/poly2tri/sweep
vpath %.h libs/poly2tri/sweep

objects = $(addprefix $(OBJDIR)/, adventure.o console.o drawing.o lua.o path.o shapes.o advancing_front.o cdt.o sweep.o sweep_context.o)

all : $(objects) $(poly2tri)
	g++ -o adventure `allegro-config --libs` -lpthread -lm -llua $(objects) $(poly2tri)

$(OBJDIR) : 
	mkdir $(OBJDIR)

$(OBJDIR)/%.o : %.cc adventure.h drawing.h lua.h path.h poly2tri.h shapes.h utils.h advancing_front.h cdt.h sweep.h sweep_context.h $(OBJDIR)
	g++ -g -c $< -o $@

.PHONY : clean
clean : 
	rm adventure $(objects)
	rmdir $(OBJDIR)
