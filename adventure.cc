#include "adventure.h"

SDL_Surface *room_hot = NULL;

bool quit = false;
bool in_console = false;

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
    SDL_Event event;
    while (SDL_PollEvent(&event))
        process_input_event(event);

    update_game();
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
    int last_ticks = 0, frames_done = 0;

    SDL_Init(SDL_INIT_EVERYTHING);
    TTF_Init();

    screen = SDL_SetVideoMode(SCREEN_WIDTH, SCREEN_HEIGHT, 0, SDL_SWSURFACE | SDL_ANYFORMAT | SDL_DOUBLEBUF);
    
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
    lua_pushnumber(script, 0);
    lua_settable(script, -3);
    lua_pop(script, 1);
    
    init_console(32);
    
    last_ticks = SDL_GetTicks();

    while (!quit) {
        if (lock_fps(FRAMERATE)) {
            update();
            frame();
            
            frames_done++;
        }
        
        if (SDL_GetTicks() - last_ticks >= 1000) {
            last_ticks = SDL_GetTicks();
            
            lua_getglobal(script, "engine");
            lua_pushstring(script, "fps");
            lua_pushnumber(script, frames_done);
            lua_settable(script, -3);
            lua_pop(script, 1);
            
            frames_done = 0;
        }
    }
    
    SDL_Quit();
    TTF_Quit();
    return 0;
}
