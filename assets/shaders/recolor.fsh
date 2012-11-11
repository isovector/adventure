varying MEDP vec2 uvVarying;
 
uniform sampler2D tex2D;
uniform float strength;
 
void main()
{
    const vec4 color = vec4(1.0, 1.0, 0.45, 1.0);
    vec4 pixel = texture2D(tex2D, uvVarying);
    gl_FragColor = pixel + pixel.a * color * strength;
}
