import subprocess
import re

from xml.dom.minidom import parse, parseString



def getTime(str):
    global settings
    ticks = 0
    
    seconds = re.search("([0-9.]+)s", str)
    if seconds: ticks += float(seconds.group(1)) * settings["fps"]
    
    frames = re.search("([0-9.]+)f", str)
    if frames: ticks += float(frames.group(1))
    return int(ticks)


def getPixel(x, y):
    global settings
    
    if settings["xflip"]: x = -x
    if settings["yflip"]: y = -y
    
    x -= settings["left"]
    y -= settings["top"]
    
    x *= settings["xscale"]
    y *= settings["yscale"]
    return (int(x), int(y))


def unpackVector(dom):
    vector = dom.getElementsByTagName("vector")[0]
    x = float(vector.getElementsByTagName("x")[0].firstChild.data)
    y = float(vector.getElementsByTagName("y")[0].firstChild.data)
    return (x, y)


events = { }
def getEvents(dom):
    global settings, events
    for keyframe in dom.getElementsByTagName("keyframe"):
        if keyframe.firstChild:
            events[getTime(keyframe.getAttribute("time"))] = keyframe.firstChild.data


tracknames = []
def getTracks(dom):
    global tracknames
    for node in dom.getElementsByTagName("meta"):
        if node.getAttribute("content") == "track":
            tracknames.append(node.getAttribute("name"))

tracks = { }
def performTracking(dom):
    global settings, tracknames, tracks
    for node in dom.getElementsByTagName("animated"):
        name = node.getAttribute("id")
        if name in tracknames:
            track = { }
            waypoints = node.getElementsByTagName("waypoint")
            for i in range(0, len(waypoints) - 1):
                x1, y1 = unpackVector(waypoints[i])
                x2, y2 = unpackVector(waypoints[i + 1])
                
                dx = x2 - x1
                dy = y2 - y1
                
                now = getTime(waypoints[i].getAttribute("time"))
                then = getTime(waypoints[i + 1].getAttribute("time"))
                duration = then - now
                for i in range(0, duration):
                    track[now + i] = getPixel(x1 + dx * i / duration, y1 + dy * i / duration)
            tracks[name] = track


settings = { }
def initSettings(dom):
    global settings
    vb = dom.getAttribute("view-box")
    bits = [float(bit) for bit in vb.split(" ")]
    
    width = bits[2] - bits[0]
    height = bits[3] - bits[1]
    
    xflip = False
    yflip = False
    
    if width < 0:
        xflip = True
        bits[0] = -bits[0]
        width = -width
    if height < 0:
        yflip = True
        bits[1] = -bits[1]
        height = -height
    
    settings = { 
                'fps': float(dom.getAttribute("fps")),
                'top': bits[1], 
                'left': bits[0], 
                'xscale': float(dom.getAttribute("width")) / width, 
                'yscale': float(dom.getAttribute("height")) / height, 
                'xflip': xflip, 
                'yflip': yflip 
            }



p = subprocess.Popen(["gzip", "-dfc", "../art/test.sifz"], stdout=subprocess.PIPE)
lines = p.stdout.readlines()

f = open("test.tmp", "w")
for line in lines: f.write(line.decode("utf-8"))
f.close()

dom = parse("./test.tmp")
dom = dom.getElementsByTagName("canvas")[0]
initSettings(dom)
getEvents(dom)
getTracks(dom)
performTracking(dom.getElementsByTagName("defs")[0])

print("test = {")
print("\tevents = {")
print("\t\t" + ",\n\t\t".join(['%d = "%s"' % (time, event) for time, event in events.items()]))
print("\t},")
print()
print("\ttracks = { }")
print("}")
print()

for name, track in tracks.items():
    print("test.tracks.%s = {" % name)
    print("\t" + ",\n\t".join(["%d = vector(%d, %d)" % (time, pos[0], pos[1]) for time, pos in track.items()]))
    print("}")
