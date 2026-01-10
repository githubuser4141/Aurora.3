//-------------------- HUD ---------------------
//HUD layer defines
#define HUD_BACKGROUND_LAYER 1 //MOJAVE EDIT ADDITION - Mojave HUD
#define HUD_PLANE 1000
#define ABOVE_HUD_PLANE 1100

#define RADIAL_BACKGROUND_LAYER 0
///1000 is an unimportant number, it's just to normalize copied layers
#define RADIAL_CONTENT_LAYER 1000

#define ADMIN_POPUP_LAYER 1


///Plane of the "splash" icon used that shows on the lobby screen. Nothing should ever be above this.
#define SPLASHSCREEN_PLANE 9999

#define LOBBY_BACKGROUND_LAYER 3
#define LOBBY_BUTTON_LAYER 4

///cinematics are "below" the splash screen
#define CINEMATIC_LAYER -1

///Plane master controller keys
#define PLANE_MASTERS_GAME "plane_masters_game"
#define PLANE_MASTERS_NON_MASTER "plane_masters_non_master" //MOJAVE EDIT ADDITION - Plane Upstream
#define PLANE_MASTERS_COLORBLIND "plane_masters_colorblind" //MOJAVE EDIT ADDITION - Plane Upstream
