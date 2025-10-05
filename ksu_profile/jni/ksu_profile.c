// Small program to do a prctl to KSU to query apps' `should unmount`

#include <errno.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>

#define CMD_IS_UID_SHOULD_UMOUNT 13
#define KERNEL_SU_OPTION 0xDEADBEEF

static bool ksuctl(int cmd, void* arg1, void* arg2) {
    uint32_t result = 0;
    prctl(KERNEL_SU_OPTION, cmd, arg1, arg2, &result);
    return result == KERNEL_SU_OPTION;
}

bool uid_should_umount(long uid, bool* should_umount) {
    bool ok = ksuctl(CMD_IS_UID_SHOULD_UMOUNT, (void*)uid, should_umount);
    return ok;
}

int main(int argc, char* argv[]) {
    if (argc <= 1) {
        fprintf(stderr, "ERROR: uid is not supplied:\n");
        fprintf(stderr, "    %s <uid>\n", argv[0]);
    }
    long uid = atol(argv[1]);
    bool should_umount;
    if (!uid_should_umount(uid, &should_umount)) {
        fprintf(stderr, "ERROR: %s\n", strerror(errno));
        return errno;
    }
    return should_umount ? 0 : 1;
}
