OBJDIR = obj
COSTDIR = game/costumes
BUILD_FLAGS = -O0 -g3
LINK_FLAGS = $(addprefix -l, SDL SDL_image SDL_gfx SDL_ttf pthread m lua)

#########################################################

c_files =  $(addsuffix .o, adventure drawing geometry input lua path tasks)
headers =  $(addsuffix .h, adventure drawing geometry input lua path tasks)
wrappers = $(addsuffix _wrap.o, geometry drawing pathfinding tasks)

#########################################################

objects =  $(addprefix $(OBJDIR)/, $(c_files) $(wrappers))
srcheaders = $(addprefix src/, $(headers))

art = $(patsubst art/%.sifz, $(COSTDIR)/%.png, $(shell find art/ -type f -name '*.sifz'))
extensions = $(shell find extensions/ -type f -name '*.mlua')
scripts = $(patsubst ./%.lua, $(OBJDIR)/%.luac, $(shell find . -type f -name '*.lua'))

extprebuild = $(OBJDIR)/extensions

#########################################################

adventure : $(OBJDIR) $(scripts) $(objects)
	g++ $(BUILD_FLAGS) -o adventure $(LINK_FLAGS) $(objects)
    
src/%_wrap.cc : src/exports/%.i $(srcheaders)
	swig -c++ -lua -o $@ $<
	@sed -i 's/"lua.h"/<lua.h>/g' $@

$(OBJDIR)/%.o : src/%.cc $(srcheaders)
	g++ $(BUILD_FLAGS) -D TASKS_LINE_OFFSET=`wc $(extprebuild) | awk '{print $$1}'` -c $< -o $@


#########################################################

$(extprebuild) : $(extensions)
	cat $(extensions) > $(extprebuild)

$(OBJDIR)/%.luac : %.lua $(extprebuild)
	@mkdir -p $(dir $@)
	@cat $(extprebuild) $< > $@
	@echo metalua -o $@ $<
	@metalua -o $@ $@
	
#########################################################

art : $(OBJDIR) $(art) $(COSTDIR)/costumes.lua

$(COSTDIR)/costumes.lua : utils/build_costume.py
	python utils/build_costume.py art > $(COSTDIR)/costumes.lua

$(COSTDIR)/%.png : art/%.sifz
	synfig -t png -o $(OBJDIR)/build.png $<
	@mkdir -p $(dir $@)
	montage $(OBJDIR)/*.png -geometry 50%x50%+0+0 -tile x1 -background none $@
	@rm $(OBJDIR)/*.png

#########################################################

.PHONY : all clean profile art clean_all

all : art adventure

profile : $(OBJDIR) $(objects)
	g++ $(BUILD_FLAGS) -p -o adventure $(LINK_FLAGS) $(objects)

$(OBJDIR) : 
	mkdir $(OBJDIR)

clean : clean_scripts
	rm adventure $(objects)
	rm $(extprebuild)
	find $(OBJDIR) -depth -type d -empty -exec rmdir {} \;

clean_scripts : 
	rm $(scripts)

clean_all : clean
	rm -r game/costumes/