OBJDIR = obj
LINK_FLAGS = $(addprefix -l, SDL SDL_image SDL_gfx SDL_ttf pthread m lua)

#########################################################

c_files =  $(addsuffix .o, adventure drawing geometry input lua path)
headers =  $(addsuffix .h, adventure drawing geometry input lua path)
wrappers = $(addsuffix _wrap.o, geometry drawing pathfinding)

#########################################################

objects =  $(addprefix $(OBJDIR)/, $(c_files) $(wrappers))
art = $(addprefix $(OBJDIR)/, santino.png)

#########################################################

adventure : $(OBJDIR) $(objects) $(art)
	g++ -o adventure $(LINK_FLAGS) $(objects)

%_wrap.cc : exports/%.i $(headers)
	swig -c++ -lua -o $@ $<
	sed -i 's/"lua.h"/<lua.h>/g' $@

art/temp : 
	mkdir art/temp

$(OBJDIR)/%.o : %.cc $(headers)
	g++ -g -c $< -o $@
    
$(OBJDIR)/%.png : art/%.sifz
	synfig -t png -o $(OBJDIR)/build.png $<
	montage $(OBJDIR)/*.png -geometry +0+0 -tile x1 -background magenta $@
	rm $(OBJDIR)/build*.png

#########################################################

.PHONY : clean profile tmpart

profile : $(OBJDIR) $(objects)
	g++ -pg -o adventure $(LINK_FLAGS) $(objects)

$(OBJDIR) : 
	mkdir $(OBJDIR)

clean : 
	rm adventure $(objects)
	rmdir $(OBJDIR)
