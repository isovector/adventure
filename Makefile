CXX = g++ 			
CXXFLAGS = -g3 -O0 -Wall -MMD $(addprefix -l, SDL SDL_image SDL_gfx SDL_ttf pthread m lua)
OBJECTS = $(patsubst ./%.cc, %.o, $(shell find . -type f -name '*.cc'))
DEPENDS = ${OBJECTS:.o=.d}
EXEC = adventure


OBJDIR = obj
COSTDIR = game/costumes

#########################################################

art = $(patsubst art/%.sifz, $(COSTDIR)/%.png, $(shell find art/ -type f -name '*.sifz'))

#########################################################

${EXEC} : ${OBJDIR} ${OBJECTS}
	${CXX} ${CXXFLAGS} ${OBJECTS} -o ${EXEC}

src/%_wrap.cc : src/exports/%.i $(srcheaders)
	swig -c++ -lua -o $@ $<
#	sed -i 's/"lua.h"/<lua.h>/g' $@

#########################################################

art : $(OBJDIR) $(art) $(COSTDIR)/costumes.lua

$(COSTDIR)/costumes.lua : utils/build_costume.py
	python utils/build_costume.py art > $(COSTDIR)/costumes.lua

$(COSTDIR)/%.png : art/%.sifz
	synfig -t png -o $(OBJDIR)/build.png $<
	mkdir -p $(dir $@)
	montage $(OBJDIR)/*.png -geometry 50%x50%+0+0 -tile x1 -background none $@
	rm $(OBJDIR)/*.png

#########################################################

.PHONY : all clean profile art clean_all

all : art adventure

profile : $(OBJDIR) $(objects)
	g++ $(BUILD_FLAGS) -p -o adventure $(LINK_FLAGS) $(objects)

$(OBJDIR) : 
	mkdir $(OBJDIR)

clean : 
	rm -rf ${DEPENDS} ${OBJECTS} ${EXEC}

clean_all : clean
	rm -r game/costumes/
	
-include ${DEPENDS}
