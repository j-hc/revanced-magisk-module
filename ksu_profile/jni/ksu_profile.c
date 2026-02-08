#include <errno.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <unistd.h>

#define KSU_INSTALL_MAGIC1 0xDEADBEEF
#define KSU_INSTALL_MAGIC2 0xCAFEBABE

#define KSU_APP_PROFILE_VER 2
#define KSU_MAX_PACKAGE_NAME 256
#define KSU_MAX_GROUPS 32
#define KSU_SELINUX_DOMAIN 64

#define KSU_IOCTL_MAGIC 'K'
#define KSU_IOCTL_UID_SHOULD_UMOUNT _IOC(_IOC_READ | _IOC_WRITE, KSU_IOCTL_MAGIC, 9, 0)
#define KSU_IOCTL_GET_MANAGER_APPID _IOC(_IOC_READ, KSU_IOCTL_MAGIC, 10, 0)
#define KSU_IOCTL_GET_APP_PROFILE _IOC(_IOC_READ | _IOC_WRITE, KSU_IOCTL_MAGIC, 11, 0)
#define KSU_IOCTL_SET_APP_PROFILE _IOC(_IOC_WRITE, KSU_IOCTL_MAGIC, 12, 0)

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

struct ksu_uid_should_umount_cmd {
    uint32_t uid;
    uint8_t should_umount;
};

struct ksu_get_manager_appid_cmd {
    uint32_t appid;
};

static int _fd = -1;
#define ksuctl(op, ...) (ioctl(_fd, op, __VA_ARGS__) >= 0)

#define REPORT_ERR() fprintf(stderr, "%s:%d ERROR: %s\n", __FILE__, __LINE__, strerror(errno));

int main(int argc, char* argv[]) {
    if (argc <= 2) {
        fprintf(stderr,
                "ksu_profile (github.com/j-hc)\n"
                "Disables \"Unmount modules\" for given package\n"
                "    Usage: %s <pkg uid> <pkg name>\n",
                argv[0]);
        return 1;
    }

    syscall(SYS_reboot, KSU_INSTALL_MAGIC1, KSU_INSTALL_MAGIC2, 0, &_fd);
    if (_fd == -1) {
        REPORT_ERR();
        return 1;
    }
    long uid = atol(argv[1]);

    struct ksu_uid_should_umount_cmd umount_cmd = {0};
    if (!ksuctl(KSU_IOCTL_UID_SHOULD_UMOUNT, &umount_cmd)) {
        REPORT_ERR();
        return 1;
    }
    if (!umount_cmd.should_umount) return 0;

    struct ksu_get_manager_appid_cmd appid_cmd = {0};
    if (!ksuctl(KSU_IOCTL_GET_MANAGER_APPID, &appid_cmd)) {
        REPORT_ERR();
        return 1;
    }

    if (setuid(appid_cmd.appid) != 0) {
        REPORT_ERR();
        return 1;
    }
    struct app_profile profile = {0};
    profile.current_uid = uid;
    if (!ksuctl(KSU_IOCTL_GET_APP_PROFILE, &profile)) {
        printf("Create profile for %s\n", argv[2]);
        profile.version = KSU_APP_PROFILE_VER;
        strncpy(profile.key, argv[2], sizeof(profile.key) / sizeof(profile.key[0]));
    }

    profile.nrp_config.use_default = false;
    profile.nrp_config.profile.umount_modules = false;

    if (!ksuctl(KSU_IOCTL_SET_APP_PROFILE, &profile)) {
        REPORT_ERR();
        return 1;
    }

    return 0;
}
