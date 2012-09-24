OBJDIR = art/obj
COSTDIR = assets/costumes

#########################################################

art = $(patsubst art/%.sifz, $(COSTDIR)/%.png, $(shell find art/ -type f -name '*.sifz')) $(patsubst art/%.png, $(COSTDIR)/%.png, $(shell find art/ -type f -name '*.png'))

#########################################################

art : $(OBJDIR) $(art) $(COSTDIR)/costumes.lua

$(COSTDIR)/costumes.lua : utils/build_costume.py
	python2 utils/build_costume.py art > $(COSTDIR)/costumes.lua

$(COSTDIR)/%.png : art/%.png
	mkdir -p $(dir $@)
	cp $< $@

$(COSTDIR)/%.png : art/%.sifz
	synfig -t png -o $(OBJDIR)/build.png $<
	mkdir -p $(dir $@)
	montage $(OBJDIR)/*.png -geometry 50%x50%+0+0 -tile x1 -background transparent -format png32 -type TruecolorMatte $@
	rm $(OBJDIR)/*.png

#########################################################

.PHONY : clean art

$(OBJDIR) : 
	mkdir -p $(COSTDIR)
	mkdir $(OBJDIR)

clean : 
	rm -r $(COSTDIR) $(OBJDIR)
