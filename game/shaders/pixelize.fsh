// from http://coding-experiments.blogspot.ca/2010/06/pixelation.html

uniform sampler2D Texture0;
varying MEDP vec2 uvVarying;

#define H 0.02
#define S ((3./2.) * H/sqrt(3.))

vec2 hexCoord(ivec2 hexIndex) {
int i = hexIndex.x;
int j = hexIndex.y;
vec2 r;
r.x = i * S;
r.y = j * H + (i%2) * H/2.;
return r;
}

ivec2 hexIndex(vec2 coord) {
ivec2 r;
float x = coord.x;
float y = coord.y;
int it = int(floor(x/S));
float yts = y - float(it%2) * H/2.;
int jt = int(floor((1./H) * yts));
float xt = x - it * S;
float yt = yts - jt * H;
int deltaj = (yt > H/2.)? 1:0;
float fcond = S * (2./3.) * abs(0.5 - yt/H);

if (xt > fcond) {
r.x = it;
r.y = jt;
}
else {
r.x = it - 1;
r.y = jt - (r.x%2) + deltaj;
}

return r;
}

void main(void)
{
vec2 xy = uvVarying.xy;
ivec2 hexIx = hexIndex(xy);
vec2 hexXy = hexCoord(hexIx);
vec4 fcol = texture2D(Texture0, hexXy);
gl_FragColor = fcol;
}