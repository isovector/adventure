#convert hot.png -sample 12.5%x12.5% -channel rgb smallhot.png
import Image
import sys

im = Image.open(sys.argv[1])
pix = im.load()

sys.stdout.write("return {\n")
sys.stdout.write("\tresolution = 16,\n\tmap = {\n")
for y in range(0, im.size[1]):
    sys.stdout.write("\t\t{")
    for x in range(0, im.size[0]):
        sys.stdout.write(str(1 if pix[x, y] == 0 else 0))
        if x != im.size[0]:
            sys.stdout.write(",")
    sys.stdout.write("}")
    
    if y != im.size[1] - 1:
        sys.stdout.write(",")
    sys.stdout.write("\n")
sys.stdout.write("\t}\n")
sys.stdout.write("}\n")
