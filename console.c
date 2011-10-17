#include "adventure.h"

#define CONSOLE_WIDTH 1280
#define CONSOLE_HEIGHT 300
#define CONSOLE_MARGIN 12

typedef struct tagRQNODE {
    char *prompt, *value;
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
    RQNODE *node = (RQNODE*)malloc(sizeof(RQNODE));
    node->next = NULL;
    node->prompt = NULL;
    node->value = NULL;

    return node;
}

void push_queue(const char *cprompt, const char *value) {
    RQNODE *node = rollqueue.head;
    rollqueue.head = node->next;
    rollqueue.tail->next = node;
    rollqueue.tail = node;
    node->next = NULL;
    if (node->value)
        free(node->value);
    if (node->prompt)
        free(node->prompt);

    node->prompt = strdup(cprompt ? cprompt : prompt);
    node->value = value ? strdup(value) : NULL;
}

LUA_WRAPVOID(push_queue, 2, string, string)

void init_console(int n) {
    rollqueue.count = n;

    RQNODE *head = alloc_rqnode();
    rollqueue.head = head;

    for (int i = 1; i < n; i++) {
        head->next = alloc_rqnode();
        head = head->next;
    }
    
    lua_register(script, "console_line", &script_push_queue);

    rollqueue.tail = head;
}

void open_console() {
    gui_fg_color = makecol(0, 0, 0);
    gui_mg_color = makecol(128, 128, 128);
    gui_bg_color = makecol(230, 220, 210);

    rectfill(screen, 0, 0, CONSOLE_WIDTH, CONSOLE_HEIGHT, gui_bg_color);
    RQNODE *node = rollqueue.head;
    for (int i = 0; i < rollqueue.count; i++) {
        if (node->value)
            textprintf_ex(screen, font, CONSOLE_MARGIN, CONSOLE_MARGIN + i * 8, gui_fg_color, -1, "%s%s", node->prompt, node->value);
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
   
    lua_getglobal(script, "repl");
    lua_pushstring(script, "line");
    lua_gettable(script, -2);
    lua_pushstring(script, input);
    lua_call(script, 1, 1);
    
    prompt[1] = lua_toboolean(script, -1) ? '>' : ' ';
    
    if (!lua_toboolean(script, -1))
        push_queue(NULL, 0);
    
    lua_pop(script, 2);
    input[0] = '\0';

    open_console();
}
