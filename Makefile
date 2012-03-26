OBJDIR = obj
LINK_FLAGS = $(addprefix -l, SDL SDL_image SDL_gfx SDL_ttf pthread m lua)

#########################################################

c_files =  $(addsuffix .o, adventure drawing geometry input lua path)
headers =  $(addsuffix .h, adventure drawing geometry input lua path)
wrappers = $(addsuffix _wrap.o, geometry drawing pathfinding)

#########################################################

objects =  $(addprefix $(OBJDIR)/, $(c_files) $(wrappers))

#########################################################

adventure : $(OBJDIR) $(objects)
	g++ -o adventure $(LINK_FLAGS) $(objects)

%_wrap.cc : exports/%.i $(headers)
	swig -c++ -lua -o $@ $<
	sed -i 's/"lua.h"/<lua.h>/g' $@

$(OBJDIR)/%.o : %.cc $(headers)
	g++ -g -c $< -o $@

#########################################################

.PHONY : clean profile

profile : $(OBJDIR) $(objects)
	g++ -pg -o adventure $(LINK_FLAGS) $(objects)

$(OBJDIR) : 
	mkdir $(OBJDIR)

clean : 
	rm adventure $(objects)
	rmdir $(OBJDIR)
