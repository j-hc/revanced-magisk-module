#include <errno.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/prctl.h>
#include <unistd.h>

#define KSU_MAX_PACKAGE_NAME 256
#define KSU_MAX_GROUPS 32
#define KSU_SELINUX_DOMAIN 64
#define KSU_APP_PROFILE_VER 2

struct root_profile {
    int32_t uid;
    int32_t gid;

    int32_t groups_count;
    int32_t groups[KSU_MAX_GROUPS];

    struct {
        uint64_t effective;
        uint64_t permitted;
        uint64_t inheritable;
    } capabilities;

    char selinux_domain[KSU_SELINUX_DOMAIN];

    int32_t namespaces;
};

struct non_root_profile {
    bool umount_modules;
};

struct app_profile {
    uint32_t version;

    char key[KSU_MAX_PACKAGE_NAME];
    int32_t current_uid;
    bool allow_su;

    union {
        struct {
            bool use_default;
            char template_name[KSU_MAX_PACKAGE_NAME];

            struct root_profile profile;
        } rp_config;

        struct {
            bool use_default;

            struct non_root_profile profile;
        } nrp_config;
    };
};

#define CMD_GET_APP_PROFILE 10
#define CMD_SET_APP_PROFILE 11
#define CMD_IS_UID_GRANTED_ROOT 12
#define CMD_IS_UID_SHOULD_UMOUNT 13
#define CMD_GET_MANAGER_UID 16

#define KERNEL_SU_OPTION 0xDEADBEEF

static bool ksuctl(int cmd, void* arg1, void* arg2) {
    uint32_t result = 0;
    prctl(KERNEL_SU_OPTION, cmd, arg1, arg2, &result);
    return result == KERNEL_SU_OPTION;
}

#define REPORT_ERR(e)                                                                  \
    ({                                                                                 \
        bool ok = (e);                                                                 \
        if (!ok) {                                                                     \
            fprintf(stderr, "%s:%d ERROR: %s\n", __FILE__, __LINE__, strerror(errno)); \
        }                                                                              \
        ok;                                                                            \
    })

int main(int argc, char* argv[]) {
    if (argc <= 2) {
        fprintf(stderr, "Usage: %s <uid> <pkg name>\n", argv[0]);
        return 1;
    }
    long uid = atol(argv[1]);
    bool should_umount = false;
    if (!REPORT_ERR(ksuctl(CMD_IS_UID_SHOULD_UMOUNT, (void*)uid, &should_umount))) return 1;
    if (!should_umount) return 0;

    long manager_uid = 0;
    if (!REPORT_ERR(ksuctl(CMD_GET_MANAGER_UID, &manager_uid, NULL))) return 1;
    if (setuid(manager_uid) != 0) {
        fprintf(stderr, "ERROR setuid: %s\n", strerror(errno));
        return 1;
    }

    struct app_profile profile = {0};
    profile.current_uid = uid;
    if (!ksuctl(CMD_GET_APP_PROFILE, &profile, NULL)) {
        printf("Create profile for %s\n", argv[2]);
        profile.version = KSU_APP_PROFILE_VER;
        strcpy(profile.key, argv[2]);
    }

    profile.nrp_config.use_default = false;
    profile.nrp_config.profile.umount_modules = false;
    if (!REPORT_ERR(ksuctl(CMD_SET_APP_PROFILE, &profile, NULL))) return 1;

    printf("Success\n");
    return 0;
}
