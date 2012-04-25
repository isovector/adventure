OBJDIR = obj
COSTDIR = game/costumes
LINK_FLAGS = $(addprefix -l, SDL SDL_image SDL_gfx SDL_ttf pthread m lua)

#########################################################

c_files =  $(addsuffix .o, adventure drawing geometry input lua path)
headers =  $(addsuffix .h, adventure drawing geometry input lua path)
wrappers = $(addsuffix _wrap.o, geometry drawing pathfinding)

#########################################################

objects =  $(addprefix $(OBJDIR)/, $(c_files) $(wrappers))
art_santino = $(addprefix santino/, walk2 walk4 walk6 walk8 idle)
art = $(addsuffix .png, $(addprefix $(COSTDIR)/, $(art_santino)))

#########################################################

adventure : $(OBJDIR) $(objects)
	g++ -o adventure $(LINK_FLAGS) $(objects)
    
%_wrap.cc : exports/%.i $(headers)
	swig -c++ -lua -o $@ $<
	sed -i 's/"lua.h"/<lua.h>/g' $@

$(OBJDIR)/%.o : %.cc $(headers)
	g++ -g -c $< -o $@

#########################################################

art : $(art) $(COSTDIR)/costumes.lua

$(COSTDIR)/costumes.lua : utils/build_costume.py
	python utils/build_costume.py art > $(COSTDIR)/costumes.lua

$(COSTDIR)/%.png : art/%.sifz
	synfig -t png -o $(OBJDIR)/build.png $<
	mkdir -p $(dir $@)
	montage $(OBJDIR)/*.png -geometry 50%x50%+0+0 -tile x1 -background none $@
	rm $(OBJDIR)/*.png

#########################################################

.PHONY : clean profile art

profile : $(OBJDIR) $(objects)
	g++ -pg -o adventure $(LINK_FLAGS) $(objects)

$(OBJDIR) : 
	mkdir $(OBJDIR)

clean : 
	rm adventure $(objects)
	rmdir $(OBJDIR)
