#include "adventure.h"

BITMAP *room_art = NULL, *room_hot = NULL;

float life = 0;

int last_key[KEY_MAX];
int quit = 0;
int fps = 0;
int in_console = 0;

volatile int ticks = 0;
sem_t semaphore_rest;


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
    
    life += 1 / (float)FRAMERATE;

    if (key[KEY_ESC] && !last_key[KEY_ESC]) quit = 1;
    if (key[KEY_F10]) open_console();

    update_game();

    for (i = 0; i < KEY_MAX; i++)
        last_key[i] = key[i];
}

// draws the foreground of a hot image
void draw_foreground(int level) {
    int y, x;
    for (y = 0; y < SCREEN_HEIGHT; y++)
    for (x = 0; x < SCREEN_WIDTH; x++)
        if ((getpixel(room_hot, x, y) & 255) == level)
            putpixel(buffer, x, y, getpixel(room_art, x, y));
}

// draws the game
void frame() {
    acquire_bitmap(buffer);

    lua_getglobal(script, "engine");
    lua_pushstring(script, "events");
    lua_gettable(script, -2);
    
    lua_pushstring(script, "draw");
    lua_gettable(script, -2);
    
    lua_call(script, 0, 0);
    lua_pop(script, 2);
    
    release_bitmap(buffer);
    blit(buffer, screen, 0, 0, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

// interrupt for the sempahore ticker
void ticker() {
    if (!in_console) {
        sem_post(&semaphore_rest);
        ticks++;
    }
}
END_OF_FUNCTION(ticker);

int main(int argc, char* argv[]) {
    int frames_done = 0;
    float old_time = 0;
    int old_ticks = 0;
    
    sem_init(&semaphore_rest, 0, 1);

    allegro_init();
    install_keyboard();
    install_mouse();
    install_timer();

    LOCK_VARIABLE(ticks);
    LOCK_FUNCTION(ticker);

    set_color_depth(32);
    set_gfx_mode(GFX_AUTODETECT_WINDOWED, SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0);

    // load resources
    buffer = create_bitmap(SCREEN_WIDTH, SCREEN_HEIGHT);
    
    enabled_paths[255] = 1;

	init_script();
    
    if (luaL_dofile(script, "game/init.lua") != 0) {
        printf("%s\n", lua_tostring(script, -1));
    }
    
    lua_setconstant(script, "screen_width", number, SCREEN_WIDTH);
    lua_setconstant(script, "screen_height", number, SCREEN_HEIGHT);
    lua_setconstant(script, "framerate", number, 60);
    
        if (luaL_dofile(script, "game/boot.lua") != 0) {
        printf("%s\n", lua_tostring(script, -1));
    }
    
    init_console(32);
    install_int_ex(&ticker, BPS_TO_TIMER(FRAMERATE));

    while (!quit) {
        sem_wait(&semaphore_rest);

        if (life - old_time >= 1) {
            fps = frames_done;
            frames_done = 0;
            old_time = life;
            
            lua_getglobal(script, "engine");
            lua_pushstring(script, "fps");
            lua_pushnumber(script, fps);
            lua_settable(script, -3);
            lua_pop(script, 1);
        }

        while (ticks > 0) {
            old_ticks = ticks;
            update();
            ticks--;

            if (old_ticks <= ticks) break;
        }

        frame();
        frames_done++;
    }

    remove_int(ticker);
    sem_destroy(&semaphore_rest);

    return 0;
}
END_OF_MAIN();
