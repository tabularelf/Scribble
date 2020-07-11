//   @jujuadams   v6.0.7e   2020-06-29

const int MAX_EFFECTS = 8;
//By default, the effect indexes are:
//0 = is an animated sprite
//1 = wave
//2 = shake
//3 = rainbow
//4 = wobble
//5 = pulse
//6 = wheel
//7 = cycle

const int MAX_ANIM_FIELDS = 17;
//By default, the data fields are:
// 0 = wave amplitude
// 1 = wave frequency
// 2 = wave speed
// 3 = shake amplitude
// 4 = shake speed
// 5 = rainbow weight
// 6 = rainbow speed
// 7 = wobble angle
// 8 = wobble frequency
// 9 = pulse scale
//10 = pulse speed
//11 = wheel amplitude
//12 = wheel frequency
//13 = wheel speed
//14 = cycle speed
//15 = cycle saturation
//16 = cycle value

const float MAX_LINES = 1000.0; //Change __SCRIBBLE_MAX_LINES in scribble_init() if you change this value!

const int WINDOW_COUNT = 4;



//--------------------------------------------------------------------------------------------------------
// Attributes, Varyings, and Uniforms


attribute vec3 in_Position;     //{X, Y, Packed character & line index}
attribute vec3 in_Normal;       //{Centre dX, Centre dY, Bitpacked effect flags}
attribute vec4 in_Colour;       //Colour. This attribute is used for sprite data if this character is a sprite
attribute vec2 in_TextureCoord; //UVs

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  u_vColourBlend;                           //4
uniform float u_fTime;                                  //1
uniform float u_fTypewriterMethod;                      //1
uniform float u_fTypewriterWindowArray[2*WINDOW_COUNT]; //8
uniform float u_fTypewriterSmoothness;                  //1
uniform float u_aDataFields[MAX_ANIM_FIELDS];           //18



//--------------------------------------------------------------------------------------------------------
// Functions
// Scroll all the way down to see the main() function for the vertex shader

//*That* randomisation function.
//I haven't found a better method yet, and this is sufficient for our purposes
float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

//Bitwise unpacking of effect flags
//The effect bits are stored in the Z-channel of the Normal attribute
void unpackFlags(float flagValue, inout float array[MAX_EFFECTS])
{
    float check = pow(2.0, float(MAX_EFFECTS)-1.0);
    for(int i = MAX_EFFECTS-1; i >= 0; i--)
    {
        if (flagValue >= check)
        {
            array[i] = 1.0;
            flagValue -= check;
        }
        else
        {
            array[i] = 0.0;
        }
        check /= 2.0;
    }
}

//Rotate the character
vec2 rotate(vec2 position, vec2 centre, float angle)
{
    vec2 delta = position.xy - centre;
    float _sin = sin(0.00872664625*angle);
    float _cos = cos(0.00872664625*angle);
    return centre + vec2(delta.x*_cos - delta.y*_sin, delta.x*_sin + delta.y*_cos);
}

//Scale the character equally on both x and y axes
vec2 scale(vec2 position, vec2 centre, float scale)
{
    return centre + scale*(position - centre);
}

//Scale the character on the x-axis
float xscale(vec2 position, vec2 centre, float scale)
{
    return centre.x + scale*(position.x - centre.x);
}

//Scale the character on the y-axis
float yscale(vec2 position, vec2 centre, float scale)
{
    return centre.y + scale*(position.y - centre.y);
}

//Oscillate the character
vec2 wave(vec2 position, float characterIndex, float amplitude, float frequency, float speed)
{
    return vec2(position.x, position.y + amplitude*sin(frequency*characterIndex + speed*u_fTime));
}

//Wheel the character around
vec2 wheel(vec2 position, float characterIndex, float amplitude, float frequency, float speed)
{
    float time = frequency*characterIndex + speed*u_fTime;
    return position.xy + amplitude*vec2(cos(time), -sin(time));
}

//Wobble the character by rotating around its central point
vec2 wobble(vec2 position, vec2 centre, float angle, float frequency)
{
    return rotate(position, centre, angle*sin(frequency*u_fTime));
}

//Pulse the character by scaling it up and down
vec2 pulse(vec2 position, vec2 centre, float characterIndex, float scale_, float frequency)
{
    float adjustedScale = 1.0 + scale_*(0.5 + 0.5*sin(frequency*(250.0*characterIndex + u_fTime)));
    return scale(position, centre, adjustedScale);
}

//Shake the character along the x/y axes
//We use integer time steps so that at low speeds characters don't jump around too much
//Lots of magic numbers in here to try to get a nice-looking shake
vec2 shake(vec2 position, float characterIndex, float magnitude, float speed)
{
    float time = speed*u_fTime + 0.5;
    float floorTime = floor(time);
    float merge = 1.0 - abs(2.0*(time - floorTime) - 1.0);
    
    //Use some misc prime numbers to try to get a varied-looking shake
    vec2 delta = vec2(rand(vec2(149.0*characterIndex + 13.0*floorTime, 727.0*characterIndex - 331.0*floorTime)),
                      rand(vec2(501.0*characterIndex - 19.0*floorTime, 701.0*characterIndex + 317.0*floorTime)));
    
    return position + magnitude*merge*(2.0*delta-1.0);
}

//Use RGBA 
vec4 handleSprites(float isSprite, vec4 colour)
{
    if (isSprite == 1.0)
    {
        float myImage    = colour.r*255.0;       //First byte is the index of this sprite
        float imageMax   = 1.0 + colour.g*255.0; //Second byte is the maximum number of images in the sprite
        float imageSpeed = colour.b;             //Third byte is half of the image speed
        float imageStart = colour.a*255.0;       //Fourth byte is the image offset
        
        float displayImage = floor(mod(imageSpeed*u_fTime + imageStart, imageMax));
        return vec4((abs(myImage-displayImage) < 1.0/255.0)? 1.0 : 0.0);
    }
    else
    {
        return colour;
    }
}

//HSV->RGB conversion function
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 P = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(P - K.xxx, 0.0, 1.0), c.y);
}

//Colour cycling for the rainbow effect
vec4 rainbow(float characterIndex, float weight, float speed, vec4 colour)
{
    return vec4(mix(colour.rgb, hsv2rgb(vec3(characterIndex + speed*u_fTime, 1.0, 1.0)), weight), colour.a);
}
                           
//Colour cycling through a defined palette
vec4 cycle(float characterIndex, float speed, float saturation, float value, vec4 colour)
{
    float max_h = 4.0; //Default to a 4-colour cycle
    
    //Special cases for 0- and 1-colour cycles
    if (colour.r < 0.003) return colour;
    if (colour.g < 0.003) return vec4(hsv2rgb(vec3(colour.r, saturation/255.0, value/255.0)), 1.0);
    if (colour.a < 0.003) max_h = 3.0; //3-colour cycle
    if (colour.b < 0.003) max_h = 2.0; //2-colour cycle
    
    float h = abs(mod((speed*u_fTime - characterIndex)/10.0, max_h));
    vec3 rgbA = hsv2rgb(vec3(colour[int(h)], saturation/255.0, value/255.0));
    vec3 rgbB = hsv2rgb(vec3(colour[int(mod(h + 1.0, max_h))], saturation/255.0, value/255.0));
    
    return vec4(mix(rgbA, rgbB, fract(h)), 1.0);
}

//Fade effect for typewriter etc.
float fade(float windowArray[2*WINDOW_COUNT], float smoothness, float index)
{
    float result = 0.0;
    float f      = 1.0;
    float head   = 0.0;
    float tail   = 0.0;
    
    for(int i = 0; i < 2*WINDOW_COUNT; i += 2)
    {
        head = windowArray[i  ];
        tail = windowArray[i+1];
        
        if (u_fTypewriterSmoothness > 0.0)
        {
            f = 1.0 - min(max((index - tail) / smoothness, 0.0), 1.0);
        }
        else
        {
            f = 1.0;
        }
        
        f *= step(index, head);
        
        result = max(f, result);
    }
    
    return result;
}



//--------------------------------------------------------------------------------------------------------



void main()
{
    //Unpack character/line index
    float characterIndex = floor(in_Position.z / MAX_LINES);
    float lineIndex      = in_Position.z - characterIndex*MAX_LINES;
    
    //Unpack data fields into variables
    //This isn't strictly necessary but it makes the shader easier to read
    float waveAmplitude   = u_aDataFields[ 0];
    float waveFrequency   = u_aDataFields[ 1];
    float waveSpeed       = u_aDataFields[ 2];
    float shakeAmplitude  = u_aDataFields[ 3];
    float shakeSpeed      = u_aDataFields[ 4];
    float rainbowWeight   = u_aDataFields[ 5];
    float rainbowSpeed    = u_aDataFields[ 6];
    float wobbleAngle     = u_aDataFields[ 7];
    float wobbleFrequency = u_aDataFields[ 8];
    float pulseScale      = u_aDataFields[ 9];
    float pulseSpeed      = u_aDataFields[10];
    float wheelAmplitude  = u_aDataFields[11];
    float wheelFrequency  = u_aDataFields[12];
    float wheelSpeed      = u_aDataFields[13];
    float cycleSpeed      = u_aDataFields[14];
    float cycleSaturation = u_aDataFields[15];
    float cycleValue      = u_aDataFields[16];
    
    //Unpack the effect flag bits into an array, then into variables for readability
    float flagArray[MAX_EFFECTS]; unpackFlags(in_Normal.z, flagArray);
    float spriteFlag  = flagArray[0];
    float waveFlag    = flagArray[1];
    float shakeFlag   = flagArray[2];
    float rainbowFlag = flagArray[3];
    float wobbleFlag  = flagArray[4];
    float pulseFlag   = flagArray[5];
    float wheelFlag   = flagArray[6];
    float cycleFlag   = flagArray[7];
    
    //Use the input vertex position from the vertex attributes. We ignore the z-component because it's used for other data
    vec2 pos = in_Position.xy;
    
    //Unpack the glyph centre. This assumes our glyph is maximum 200px wide and gives us 1 decimal place
    vec2 centre;
    centre.y = floor(in_Normal.x/2000.0);
    centre.x = in_Normal.x - centre.y*2000.0;
    centre = pos + (centre - 1000.0)/10.0;
    
    //Vertex animation
    pos.xy = wobble(pos, centre, wobbleFlag*wobbleAngle, wobbleFrequency);
    pos.xy = pulse( pos, centre, characterIndex, pulseFlag*pulseScale, pulseSpeed);
    pos.xy = wave(  pos, characterIndex, waveFlag*waveAmplitude, waveFrequency, waveSpeed); //Apply the wave effect
    pos.xy = wheel( pos, characterIndex, wheelFlag*wheelAmplitude, wheelFrequency, wheelSpeed); //Apply the wheel effect
    pos.xy = shake( pos, characterIndex, shakeFlag*shakeAmplitude, shakeSpeed); //Apply the shake effect
    
    //Colour
    v_vColour  = handleSprites(spriteFlag, in_Colour); //Use RGBA information to filter out sprites
    if ((spriteFlag < 0.5) && (cycleFlag > 0.5)) v_vColour = cycle(characterIndex, cycleSpeed, cycleSaturation, cycleValue, v_vColour); //Cycle colours through the defined palette
    v_vColour  = rainbow(characterIndex, rainbowFlag*rainbowWeight, rainbowSpeed, v_vColour); //Cycle colours for the rainbow effect
    v_vColour *= u_vColourBlend; //And then blend with the blend colour/alpha
    
    //Apply fade (if we're given a method)
    if (u_fTypewriterMethod != 0.0)
    {
        //Choose our index based on what method's being used: if the method value == 1.0 then we're using character indexes, otherwise we use line indexes
        float index = (abs(u_fTypewriterMethod) == 1.0)? characterIndex : lineIndex;
        v_vColour.a *= fade(u_fTypewriterWindowArray, u_fTypewriterSmoothness, index + 1.0);
    }
    
    //Texture
    v_vTexcoord = in_TextureCoord;
    
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION]*vec4(pos, 0.0, 1.0);
}