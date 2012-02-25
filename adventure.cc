#include "adventure.h"

SDL_Surface *room_art = NULL, *room_hot = NULL;

int quit = 0;
int in_console = 0;


// updates the regular game state
void update_game() {
    update_mouse();
    
    // update lua's game loop
    lua_getglobal(script, "events");
    lua_pushstring(script, "game");
    lua_gettable(script, -2);
    lua_pushstring(script, "tick");
    lua_gettable(script, -2);
    
    lua_pushstring(script, "game");
    lua_call(script, 1, 0);
    lua_pop(script, 2);
    
    return;
}

// generic update - dispatches on gamestate
void update() {
    int i;
    
    SDL_Event event;
    while (SDL_PollEvent(&event)) {
        switch (event.type) {
            case SDL_KEYDOWN: {
                if (event.key.keysym.sym == SDLK_ESCAPE) {
                    quit = true;
                } else if (event.key.keysym.sym == SDLK_F10) {
                    //open_console(1);
                }
            } break;

            case SDL_KEYUP: {
                // nothing yet!
            } break;
            
            case SDL_QUIT: {
                quit = true;
            } break;

            default: {
            } break;
        }
      }

    update_game();
}

// draws the foreground of a hot image
void draw_foreground(int level) {
    int y, x;
    
    SDL_LockSurface(screen);

    for (y = 0; y < SCREEN_HEIGHT; y++)
    for (x = 0; x < SCREEN_WIDTH; x++)
        if ((getpixel(room_hot, x, y) & 255) == level)
            putpixel(screen, x, y, getpixel(room_art, x, y));
        
    SDL_UnlockSurface(screen);
}

// draws the game
void frame() {
    lua_getglobal(script, "engine");
    lua_pushstring(script, "events");
    lua_gettable(script, -2);
    
    lua_pushstring(script, "draw");
    lua_gettable(script, -2);
    
    lua_call(script, 0, 0);
    lua_pop(script, 2);
    
    SDL_Flip(screen);
}

bool lock_fps(int framerate) {
    static float lastTime = 0.0f;
    float currentTime = SDL_GetTicks() * 0.001f;

    if ((currentTime - lastTime) > (1.0f / framerate)) {
        lastTime = currentTime;
        return true;
    }

    return false;
}


int main(int argc, char* argv[]) {
    SDL_Init(SDL_INIT_EVERYTHING);
    TTF_Init();

    screen = SDL_SetVideoMode(SCREEN_WIDTH, SCREEN_HEIGHT, 32, SDL_DOUBLEBUF | SDL_HWSURFACE);
    SDL_ShowCursor(false);
    SDL_WM_SetCaption("Adventure // Corpus Damaged", NULL);
    
    font = TTF_OpenFont("resources/FreeMono.ttf", 18);
    
    enabled_paths[255] = 1;

	init_script();
    init_keys();
    
    lua_setconstant(script, "screen_width", number, SCREEN_WIDTH);
    lua_setconstant(script, "screen_height", number, SCREEN_HEIGHT);
    lua_setconstant(script, "framerate", number, 60);
    
    boot_module();
    
    lua_getglobal(script, "engine");
    lua_pushstring(script, "fps");
    lua_pushnumber(script, 60);
    lua_settable(script, -3);
    lua_pop(script, 1);
    
    init_console(32);

    while (!quit) {
        if(lock_fps(FRAMERATE)) {
            /*lua_getglobal(script, "engine");
            lua_pushstring(script, "fps");
            lua_pushnumber(script, fps);
            lua_settable(script, -3);
            lua_pop(script, 1);*/
            
            update();
            frame();
            SDL_Delay(1);
        }
    }
    
    SDL_Quit();
    TTF_Quit();
    return 0;
}
