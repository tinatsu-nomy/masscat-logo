////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Post_ScreenTex.fx ver0.0.4  テクスチャを画面サイズにスケーリングして貼り付けます(ポストエフェクトver)
//  作成: 針金P( 舞力介入P氏のGaussian.fx改変 )
//  改変: 乃美ちなつ( @tinamxts )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ここのパラメータを変更してください
#define UseTex  1                   // 1:テクスチャ, 2:アニメGIF･APNG, 3:Screen.bmpアニメ
#define TexFile "MassCat_W.png"     // 画面に貼り付けるテクスチャファイル名
#define AnimeStart 0.0              // アニメGIF･APNGの場合のアニメーション開始時間(単位：秒)(アニメGIF･APNG以外では無視)
#define TexSzWidth  300             // 横幅 (1920に対する比率)
#define TexSzHeight TexSzWidth      // 高さ

// 解らない人はここから下はいじらないでね
////////////////////////////////////////////////////////////////////////////////////////////////

// MMM UIコントロール
float3 MMMColorKey <      // カラーキーの色(RGB指定)
   string UIName = "カラーキーの色";
   string UIWidget = "Color";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float3(0.0, 0.0, 0.0);

float MMMThreshold <   // カラーキーの閾値
   string UIName = "キー閾値";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

// アクセサリパラメータ
float PostionX : CONTROLOBJECT < string name = "(self)"; string item = "X"; >;
float PostionY : CONTROLOBJECT < string name = "(self)"; string item = "Y"; >;
float3 AcsOffset : CONTROLOBJECT < string name = "(self)"; string item = "Rxyz"; >;
float AcsR : CONTROLOBJECT < string name = "(self)"; string item = "Z"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float Zoom : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
static float3 ColorKey = saturate( AcsOffset );             // カラーキーの色(RGB指定)
static float Threshold = saturate( degrees(AcsR) ) - 0.01f; // カラーキーの閾値

// スクリーンサイズ
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5,0.5)/ViewportSize;

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;

// 位置
static float2 TexSz = float2( TexSzWidth, TexSzHeight ) / 2 * Zoom * 0.1f * ViewportSize.x / 1920;
static float2 Postion = float2( PostionX, -PostionY ) / float2( 100, 100 ) * ViewportSize / 2;
static float2 PostionSta = Postion + ViewportSize / 2 - TexSz / 2;
static float2 PostionEnd = PostionSta + TexSz;

// レンダリングターゲットのクリア値
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

#if(UseTex == 1)
// 画面に貼り付けるテクスチャ
texture2D screen_tex <
    string ResourceName = TexFile;
>;
sampler TexSampler = sampler_state {
    texture = <screen_tex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

#endif

#if(UseTex == 2)
// 画面に貼り付けるアニメーションテクスチャ
texture screen_tex : ANIMATEDTEXTURE <
    string ResourceName = TexFile;
    float Offset = AnimeStart;
>;
sampler TexSampler = sampler_state {
    texture = <screen_tex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
#endif

#if(UseTex == 3)
// オブジェクトのテクスチャ
texture ObjectTexture: MATERIALTEXTURE;
sampler TexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
#endif

////////////////////////////////////////////////////////////////////////////////////////////////
// 画面描画

struct VS_OUTPUT {
    float4 Pos			: POSITION;
    float2 Tex			: TEXCOORD0;
};

// 頂点シェーダ
VS_OUTPUT VS_ScreenTex( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

// ピクセルシェーダ
float4 PS_ScreenTex( float2 Tex: TEXCOORD0 ) : COLOR
{

    float4 Color = { 0.0f, 0.0f, 0.0f, 0.0f };

    // テクスチャ適用
    float2 xy = ViewportSize * Tex;
    if ( PostionSta.x <= xy.x && xy.x <= PostionEnd.x &&
         PostionSta.y <= xy.y && xy.y <= PostionEnd.y) {
        float2 lxy = ( xy - PostionSta ) / TexSz;
        Color = tex2D( TexSampler, lxy );
    }
    if((Threshold + MMMThreshold) > 0.0f){
       // カラーキー透過
       float len = length(Color.rgb - saturate(ColorKey+MMMColorKey));
       if( len <= (Threshold + MMMThreshold) ) Color.a = 0;
    }
    Color.a *= AcsTr;

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique ScreenTexTech <
    string Script = 
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color; Clear=Depth;"
            "ScriptExternal=Color;"
	    "Pass=ScreenTexPass;"
    ;
> {
    pass ScreenTexPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_2_0 VS_ScreenTex();
        PixelShader  = compile ps_2_0 PS_ScreenTex();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////

