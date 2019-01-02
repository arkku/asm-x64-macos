#include "kkasm.h"

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

    #define upper_bound 11

    print("Testing randuniform(");
    printi(upper_bound);
    print(")...\n");

    int64_t count[upper_bound] = { 0 };
    for (int64_t i = 10000000; i; --i) {
        uint64_t x = randuniform(upper_bound);
        count[x]++;
    }
    for (int64_t i = 0; i < upper_bound; ++i) {
        print("count[");
        printi(i);
        print("] = ");
        printi(count[i]);
        putchar('\n');
    }

    return 0;
}
