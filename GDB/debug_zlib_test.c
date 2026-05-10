#include <zlib.h>
#include <stdio.h>

int main() {
    unsigned long adler = adler32(0L, Z_NULL, 0);
    printf("%lu\n", adler);
    return 0;
}
