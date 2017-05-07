/* See the file "LICENSE" for the full license governing this code. */

Texture2D shaderTexture : register(t0);
SamplerState SampleType : register(s0);
static const float weight[11] = 
{
0.000001f,	
0.000088f,	
0.002289f,	
0.023204f,
0.092564f,	
0.146632f,
0.092564f,
0.023204f,
0.002289f,
0.000088f,
0.000001f,
};
struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;

    float2 texCoord1 : TEXCOORD1;
    float2 texCoord2 : TEXCOORD2;
    float2 texCoord3 : TEXCOORD3;
    float2 texCoord4 : TEXCOORD4;
    float2 texCoord5 : TEXCOORD5;
	float2 textCordsPos[11] : TEXCOORD6;
	int neightRange : PSIZE0;

};

float4 main(InputType input) : SV_TARGET
{
    float weight0, weight1, weight2;
    float4 colour;

	// Create the weights that each neighbor pixel will contribute to the blur.
	weight0 = 0.4062f;
    weight1 = 0.2442f;
    weight2 = 0.0545f;

	// Initialize the colour to black.
    colour = float4(0.0f, 0.0f, 0.0f, 0.0f);

     //Add the nine horizontal pixels to the colour by the specific weight of each.
    colour += shaderTexture.Sample(SampleType, input.texCoord1) * weight2;
    colour += shaderTexture.Sample(SampleType, input.texCoord2) * weight1;
    colour += shaderTexture.Sample(SampleType, input.texCoord3) * weight0;
    colour += shaderTexture.Sample(SampleType, input.texCoord4) * weight1;
    colour += shaderTexture.Sample(SampleType, input.texCoord5) * weight2;


	int textPos = 0;
 	for (int i = -input.neightRange; i < input.neightRange + 1; i++)
	{
		//colour += shaderTexture.Sample(SampleType, input.textCordsPos[textPos]) * weight[input.neightRange  -((int)(5 + input.neightRange)/2)];
		 


		textPos++;
	}
	// Set the alpha channel to one.
    colour.a = 1.0f;

    return colour;
}
