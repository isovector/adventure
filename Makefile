OBJDIR = art/obj
COSTDIR = assets/costumes
ITEMDIR = assets/items

#########################################################

art = $(patsubst art/%.sifz, $(COSTDIR)/%.png, $(shell find art/ -type f -name '*.sifz')) $(patsubst art/%.png, $(COSTDIR)/%.png, $(shell find art/ -type f -name '*.png'))
items = $(patsubst %.png, %.lua, $(shell find $(ITEMDIR)/ -type f -name '*.png')) 

#########################################################

art : $(OBJDIR) $(art) $(COSTDIR)/costumes.lua

items : $(items)

assets/services/build-costumes.lua : utils/build_costume.py
	python2 utils/build_costume.py art > $(COSTDIR)/costumes.lua

$(COSTDIR)/%.png : art/%.png
	mkdir -p $(dir $@)
	cp $< $@

$(COSTDIR)/%.png : art/%.sifz
	synfig -t png -o $(OBJDIR)/build.png $<
	mkdir -p $(dir $@)
	montage $(OBJDIR)/*.png -geometry 50%x50%+0+0 -tile x1 -background transparent -format png32 -type TruecolorMatte $@
	rm $(OBJDIR)/*.png

$(ITEMDIR)/%.lua : $(ITEMDIR)/%.png
	lua utils/build_item.lua `basename -s .png $<` > $@

#########################################################

.PHONY : clean art

$(OBJDIR) : 
	mkdir -p $(COSTDIR)
	mkdir $(OBJDIR)

clean : 
	rm -r $(COSTDIR) $(OBJDIR)
