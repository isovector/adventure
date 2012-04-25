import glob
import os
import re
import subprocess
import sys
from xml.dom.minidom import parse, parseString

def getFrames(file):
    p = subprocess.Popen(["gzip", "-dfc", file], stdout=subprocess.PIPE)
    lines = p.stdout.readlines()

    f = open("obj/test.tmp", "w")
    for line in lines: f.write(line.decode("utf-8"))
    f.close()

    dom = parse("obj/test.tmp")
    dom = dom.getElementsByTagName("canvas")[0]
    
    fps = float(dom.getAttribute("fps"))
    
    str = dom.getAttribute("end-time")
    
    ticks = 0
    seconds = re.search("([0-9.]+)s", str)
    if seconds: ticks += float(seconds.group(1)) * fps
    frames = re.search("([0-9.]+)f", str)
    if frames: ticks += float(frames.group(1))
    
    return { 
            'file': "game/costumes/%%s/%s.png" % os.path.splitext(os.path.basename(file))[0],
            'fps': fps,
            'frames' : int(ticks)
    }

print("local cost = nil")
for path in glob.iglob(sys.argv[1] + "/*"):
    if os.path.isdir(path):
        poses = { }
        anim = os.path.basename(path)
        
        for file in glob.iglob(path + "/*.sifz"):
            base = os.path.basename(file)
            base = os.path.splitext(base)[0]
            
            result = re.search("([a-z]+)([0-9]*)", base)
            pose = result.group(1)
            dir = result.group(2)
            
            if dir == "":
                dir = "5"
            
            if not pose in poses:
                poses[pose] = {}
                
            poses[pose][dir] = getFrames(file)
            
        print("cost = Costume.new()")
        print("cost.poses = {")
        for name, pose in poses.items():
            print("\t%s = { }," % name)
        print("\tnil")
        print("}")
        
        for name, pose in poses.items():
            for dir, data in pose.items():
                firstpass = "cost.poses.%s[%s] = Animation.new(load.image(\"%s\"), %d, 1, %d)" % (name, dir, data["file"], data["frames"], data["fps"])
                print(firstpass % anim)
                
                if name == "walk" or name == "idle":
                    print("cost.poses.%s[%s].loops = true" % (name, dir))
        
        print("costumes.%s = cost\n" % anim)
