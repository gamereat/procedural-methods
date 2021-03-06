/* See the file "LICENSE" for the full license governing this code. */

Texture2D texture0 : register(t0);
SamplerState Sampler0 : register(s0);

cbuffer LightBuffer : register(cb0)
{
    float alphaBlendValue;
    float3 padding;
}
struct InputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
};


float4 main(InputType input) : SV_TARGET
{
    float4 textureColor;

	float4 colour = float4(1.0f, 0.0f, 0.0f, 0.1f);

    // Sample the pixel color from the texture using the sampler at this texture coordinate location.
    textureColor = texture0.Sample(Sampler0, input.tex);

    textureColor.a = alphaBlendValue;
    return textureColor;
}