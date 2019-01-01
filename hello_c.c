#include "mac64io.h"

int main(int argc, char *argv[]) {
    print("Hello from C!\n");
    for (int i = 0; i < argc; ++i) {
        print("argv[");
        printi(i);
        print("] = \"");
        print(argv[i]);
        print("\" (length ");
        printi(strlen(argv[i]));
        putchar(')');
        int64_t value = parseint(argv[i]);
        if (value || strcmp("0", argv[i]) == 0) {
            print(", integer value = ");
            printi(value);
        }
        putchar('\n');
    }
    return 0;
}
