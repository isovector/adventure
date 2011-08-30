#include "adventure.h"

#define CONSOLE_WIDTH 1280
#define CONSOLE_HEIGHT 300
#define CONSOLE_MARGIN 12

typedef struct tagRQNODE {
    char *value;
    int is_result;
    struct tagRQNODE *next;
} RQNODE;

struct tagROLLQUEUE {
    int count;
    RQNODE *head;
    RQNODE *tail;
} rollqueue;

char input[1024] = "";

DIALOG the_dialog[] = {
    { d_edit_proc,  CONSOLE_MARGIN, CONSOLE_HEIGHT - CONSOLE_MARGIN - 8, CONSOLE_WIDTH - CONSOLE_MARGIN * 2, 8, 0, 0, 0, D_EXIT, 1024, 0, (void*) input, NULL, NULL },
    { d_yield_proc, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL },
    { NULL,         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, NULL, NULL, NULL }
};

RQNODE *alloc_rqnode() {
    RQNODE *node = (RQNODE*)malloc(sizeof(RQNODE));
    node->next = NULL;
    node->value = NULL;
    node->is_result = 0;

    return node;
}

void push_queue(const char *value, int result) {
    RQNODE *node = rollqueue.head;
    rollqueue.head = node->next;
    rollqueue.tail->next = node;
    rollqueue.tail = node;
    node->next = NULL;
    if (node->value)
        free(node->value);

    node->value = value ? strdup(value) : NULL;
    node->is_result = result;
}

void init_console(int n) {
    rollqueue.count = n;

    RQNODE *head = alloc_rqnode();
    rollqueue.head = head;

    for (int i = 1; i < n; i++) {
        head->next = alloc_rqnode();
        head = head->next;
    }

    rollqueue.tail = head;
}

void open_console() {
    char postupdate[1031];

    gui_fg_color = makecol(0, 0, 0);
    gui_mg_color = makecol(128, 128, 128);
    gui_bg_color = makecol(230, 220, 210);

    rectfill(screen, 0, 0, CONSOLE_WIDTH, CONSOLE_HEIGHT, gui_bg_color);
    RQNODE *node = rollqueue.head;
    for (int i = 0; i < rollqueue.count; i++) {
        if (node->value)
            textprintf_ex(screen, font, CONSOLE_MARGIN, CONSOLE_MARGIN + i * 8, gui_fg_color, -1, node->is_result ? "%s" : "> %s", node->value);
        node = node->next;
    }

    set_dialog_color(the_dialog, gui_fg_color, gui_mg_color);
    in_console = 1;
    do_dialog(the_dialog, 0);
    in_console = 0;

    if (strlen(input) == 0)
        return;

    int top = lua_gettop(script);

    sprintf(postupdate, "%s", input);

    if (!strchr(input, '=') && strncmp(input, "function", 8) != 0)
        sprintf(postupdate, "return %s", input);

    push_queue(input, 0);
    luaL_dostring(script, postupdate);

    for (int i = lua_gettop(script) - top; i >= 1; i--) {
        if (lua_istable(script, -i)) {
            lua_getglobal(script, "table");
            lua_pushstring(script, "serialize");
            lua_gettable(script, -2);
            lua_pushvalue(script, -i - 2);
            lua_call(script, 1, 1);
            push_queue(lua_tostring(script, -1), 1);
            lua_pop(script, 2);
        } else if (!(lua_isstring(script, -i) || lua_isnumber(script, -i))) {
            lua_getglobal(script, "type");
            lua_pushvalue(script, -i - 1);
            lua_call(script, 1, 1);
            push_queue(lua_tostring(script, -1), 1);
            lua_pop(script, 1);
        } else {
            push_queue(lua_tostring(script, -i), 1);
        }
    }

    lua_pop(script, lua_gettop(script) - top);
    input[0] = '\0';

    push_queue(NULL, 0);
    open_console();
}
