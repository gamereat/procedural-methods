// BaseApplication.h
// Contains base application functionality. For inheritance purposes.
#ifndef _BASEAPPLICATION_H_
#define _BASEAPPLICATION_H_


 
// Includes
#include "input.h"
#include "d3d.h"
#include "camera.h"
#include "timer.h"
#include "../imgui/examples/directx11_example/imgui_impl_dx11.h"
 class BaseApplication
{
public:

	BaseApplication();
	~BaseApplication();
	virtual void init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input *in);

	virtual bool Frame();
	float screenWidth = 800;
	float screenHeight = 600;
	bool isFullScreen = false;
	bool isVsyncEnabled = false;
	float screenDepth = 200.0f;	// 1000.0f
	float sceenNear = 0.1f;		//0.1f

protected:
	virtual void HandleInput(float);
	virtual bool Render() = 0;
	virtual void CreateMainMenuBar() = 0;
	
	/*
		Used to open sub menu systems that can be either open or closed from the
		main menu bar
	*/
	virtual void OpenSubMenus();
protected:
	HWND wnd;
	int sWidth, sHeight;
	int deltax, deltay;	// for mouse movement
	POINT cursor;
	Input* m_Input;
	D3D* direct3D;
	Camera* m_Camera;
	Timer* m_Timer;
	
private:
	// Create the starting menu which should stay statics between applications
	static bool directxSetting;
	static bool imguiMetrics;
	static bool imguiStyle;
	static bool applicationInformation;
	static bool applicationFPS;
	static bool mouseInformation;
	static bool keyboardInformation;

};	

#endif