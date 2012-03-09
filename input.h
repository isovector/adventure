#ifndef ADVENTURE_INPUT_H
#define ADVENTURE_INPUT_H

#include "adventure.h"

void init_keys();
void process_input_event(const SDL_Event &event);
void update_key_state(int key, bool down);

#define lua_setkey(key) { \
                            std::string data = #key; \
                            std::transform(data.begin(), data.end(), data.begin(), ::tolower); \
                            key_mappings[SDLK_##key] = data; \
                            lua_pushstring(script, data.c_str()); \
                            lua_pushboolean(script, false); \
                            lua_settable(script, -3); \
                        }

#endif
