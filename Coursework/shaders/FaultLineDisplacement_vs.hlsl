// texture vertex shader
// Basic shader for rendering textured geometry

cbuffer MatrixBuffer : register(cb0)
{
    matrix worldMatrix;
    matrix viewMatrix;
    matrix projectionMatrix;
    matrix lightViewMatrix[4];
    matrix lightProjectionMatrix[4];
};
cbuffer CammeraBuffer : register(cb1)
{
    float3 cammeraPostion;
    float padding;
}
cbuffer LightBuffer2 : register(cb2)
{
    float4 lightPosition[4];
};
cbuffer FaltLineDisplacementBuffer : register(cb3)
{
    /*
    Number of iterations to complete
    */
    int numberOfIterations;

    /*
    The starting displacment value 
    */
    float startingDisplacement;

    /*
    The minimum value the last displacement will set to be 
    */
    float minimumDisplacement;
    /*
    SmoothingValue
    */
    float smoothingValue;
    /*

    2D array holding the diffrent random points on the surface which should be sued to complete fault line displ


    Using heavy packing on varrible. 
    x and y being the first 2 random points on the surface,
    z and w beingthe second random point on the surface
    Note 1000 will be the maxium number of iterations

    */
    int4 interationsRandomPoints[2500];

    /*
    IF fault line displacement is active
    */
    int enableFaultLineDisplacement;

    float3 padding2;

}

struct InputType
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
};

struct OutputType
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
    float4 lightViewPosition[4] : TEXCOORD1;
    float3 lightPos[4] : TEXCOORD5;
    float3 position3D : TEXCOORD10;
    float3 viewDirection : TEXCOORD11;
};

float FaultLineDisplacement(float x, float z);
float FaultLineDisplacement(float2 xz);
float3 Smoothing(float smoothingValue, float3 position, float3 pointAbove, float3 pointBellow, float3 pointLeft, float3 pointRight);
float3 CaculateNormalMap(float3 position);
OutputType main(InputType input)
{
	OutputType output;
    float4 worldPosition;

    //// Swap displacement around if entered wrong way around 
    //if (minimumDisplacement > startingDisplacement)
    //{
    //    float temp = startingDisplacement;

    //    startingDisplacement = minimumDisplacement;

    //    minimumDisplacement = temp;

    //}


    // Change the position vector to be 4 units for proper matrix calculations.
    input.position.w = 1.0f;

 
    if (enableFaultLineDisplacement)
    {
        
        input.position.y = FaultLineDisplacement(input.position.x, input.position.z);

        output.normal=  CaculateNormalMap(input.position.xyz);

    }else
    {
        	// Calculate the normal vector against the world matrix only.
        output.normal = mul(input.normal, (float3x3)worldMatrix);
	
           // Normalize the normal vector.
        output.normal = normalize(output.normal);
    }
    

	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position, worldMatrix);
    output.position = mul(output.position, viewMatrix);
    output.position = mul(output.position, projectionMatrix);
     

    for (int i = 0; i < 4; i++)
    {
		// Calculate the position of the vertice as viewed by the light source.
        output.lightViewPosition[i] = mul(input.position, worldMatrix);
        output.lightViewPosition[i] = mul(output.lightViewPosition[i], lightViewMatrix[i]);
        output.lightViewPosition[i] = mul(output.lightViewPosition[i], lightProjectionMatrix[i]);
    }
	// Store the texture coordinates for the pixel shader.
    output.tex = input.tex;
    

    // Calculate the position of the vertex in the world.
    worldPosition = mul(input.position, worldMatrix);

	// Determine the viewing direction based on the position of the camera and the position of the vertex in the world.
  
      output.viewDirection = cammeraPostion.xyz - worldPosition.xyz;

	// Normalize the viewing direction vector.
    output.viewDirection = normalize(output.viewDirection);

	// world position of vertex
    output.position3D = mul(input.position, worldMatrix);

    for (int i = 0; i < 4; i++)
    {
		// Determine the light position based on the position of the light and the position of the vertex in the world.
        output.lightPos[i] = lightPosition[i].xyz - worldPosition.xyz;

		// Normalize the light position vector.
        output.lightPos[i] = normalize(output.lightPos[i]);
    }
 
 

    return output;
}



float3 CaculateNormalMap(float3 position)
{
    float3 normal;

    float3 offset = float3(1.0, 1.0, 0.0);
    float left = FaultLineDisplacement(position.xz - offset.xz);
    float right = FaultLineDisplacement(position.xz + offset.xz);
    float bellow = FaultLineDisplacement(position.xz - offset.zy);
    float under = FaultLineDisplacement(position.xz + offset.zy);

    normal.x = left - right;
    normal.y = bellow - under;
    normal.z = 2.0;
    return normal = normalize(normal);
    
}
float FaultLineDisplacement(float2 xz)
{
    return FaultLineDisplacement(xz.x, xz.y);

}

float FaultLineDisplacement(float x, float z)
{
     
    float yAxisChange = 0;


    float displacement = startingDisplacement;
    for (int iter = 0; iter < numberOfIterations; iter++)
    {



        float2 randPoint1, randPoint2;
        
        randPoint1 = float2((float) interationsRandomPoints[iter].x, (float) interationsRandomPoints[iter].y);
        randPoint2 = float2((float) interationsRandomPoints[iter].z, (float) interationsRandomPoints[iter].w);


        float a = (float) ((float) randPoint2.y - (float) randPoint1.y);
        float b = (float) -((float) randPoint2.x - (float) randPoint1.x);
        float c = (float) (-(float) randPoint1.x * ((float) randPoint2.y - (float) randPoint1.y)) + ((float) randPoint1.y * ((float) randPoint2.x - (float) randPoint1.x));
  


        if (((a * z) + (b * x) - c) > 0)
        {          
            yAxisChange += displacement;
        }
        else
        {
            yAxisChange -= displacement;
        }

       
        if (iter < numberOfIterations)
        {
            displacement = startingDisplacement - ((float) iter / (float) numberOfIterations) * ((float) displacement - (float) minimumDisplacement);
        }
        else
        {
            displacement = startingDisplacement;
        }
    }




    return yAxisChange;

}




 