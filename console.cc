#include "adventure.h"

#define CONSOLE_WIDTH 1280
#define CONSOLE_HEIGHT 300
#define CONSOLE_MARGIN 12

typedef struct tagRQNODE {
    string prompt, value;
    struct tagRQNODE *next;
} RQNODE;

struct tagROLLQUEUE {
    int count;
    RQNODE *head;
    RQNODE *tail;
} rollqueue;

char input[1024] = "";
char prompt[] = ">  ";

DIALOG consolediag[] = {
    { d_edit_proc,  CONSOLE_MARGIN + 20, CONSOLE_HEIGHT - CONSOLE_MARGIN - 8, CONSOLE_WIDTH - CONSOLE_MARGIN * 2, 8, 0, 0, 0, D_EXIT, 1024, 0, (void*) input, NULL, NULL },
    { d_yield_proc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
    { NULL,         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL }
};

RQNODE *alloc_rqnode() {
    RQNODE *node = new RQNODE;
    
    node->next = NULL;
    node->prompt = "";
    node->value = "";

    return node;
}

void push_queue(const char *cprompt, const char *value) {
    RQNODE *node = rollqueue.head;
    
    rollqueue.head = node->next;
    rollqueue.tail->next = node;
    rollqueue.tail = node;
    node->next = NULL;
    
    node->prompt = cprompt ? cprompt : prompt;
    node->value = value;
}

int script_push_queue(lua_State *L) {
    CALL_ARGS(2)
    CALL_TYPE(string)
    CALL_TYPE(string)
    CALL_ERROR("push_queue expects (string, string)")

    push_queue(lua_tostring(L, 1), lua_tostring(L, 2));
    return 0;
}

void open_console(int repeat) {
    int i;
	RQNODE *node;
    
    //drawing_mode(DRAW_MODE_SOLID, NULL, 0, 0);
    
    gui_fg_color = makecol(0, 0, 0);
    gui_mg_color = makecol(128, 128, 128);
    gui_bg_color = makecol(230, 220, 210);

    rectfill(screen, 0, 0, CONSOLE_WIDTH, CONSOLE_HEIGHT, gui_bg_color);
    node = rollqueue.head;
    for (i = 0; i < rollqueue.count; i++) {
        if (node->value.size() > 0) {
            stringstream sstr;
            sstr << node->prompt << node->value;
            
            textprintf_ex(screen, font, CONSOLE_MARGIN, CONSOLE_MARGIN + i * 8, gui_fg_color, -1, "%s", sstr.str().c_str());
        }
        node = node->next;
    }

    textprintf_ex(screen, font, CONSOLE_MARGIN, CONSOLE_HEIGHT - CONSOLE_MARGIN - 8, gui_fg_color, -1, "%s", prompt);
    
    set_dialog_color(consolediag, gui_fg_color, gui_mg_color);
    in_console = 1;
    
    do_dialog(consolediag, 0);
    in_console = 0;

    if (strlen(input) == 0)
        return;

    push_queue(prompt, input);
    
    lua_getglobal(script, "events");
    lua_pushstring(script, "console");
    lua_gettable(script, -2);
    lua_pushstring(script, "input");
    lua_gettable(script, -2);
    lua_pushstring(script, input);
    lua_call(script, 1, 1);
    
    // this is broken! fix it somehow :)
    //prompt[1] = lua_toboolean(script, -1) ? '>' : ' ';
    
    if (!lua_toboolean(script, -1))
        push_queue(NULL, 0);
    
    lua_pop(script, 2);
    
    input[0] = '\0';
    
    if (repeat)
        open_console(repeat);
}

int script_open_console(lua_State *L) {
    if (lua_gettop(L) > 0 && !lua_isboolean(L, 1)) {
        lua_pushstring(L, "open_console expects ([boolean])");
        lua_error(L);
    }
    
    clear_keybuf();
    
    if (lua_gettop(L) == 1)
        open_console(lua_toboolean(L, 1));
    else
        open_console(1);
    
    return 0;
}

void init_console(int n) {
    RQNODE *head = alloc_rqnode();
    int i;
    
    rollqueue.count = n;
    rollqueue.head = head;

    for (i = 1; i < n; i++) {
        head->next = alloc_rqnode();
        head = head->next;
    }
    
    lua_register(script, "console_line", &script_push_queue);
    lua_register(script, "open_console", &script_open_console);

    rollqueue.tail = head;
}