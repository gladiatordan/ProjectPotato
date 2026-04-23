#pragma once
#include <glaze/glaze.hpp>
#include <cstdint>
#include <string>
#include <vector>


namespace potato::models {

    // Alignment set to 4 as per your architectural plan for 32-bit compat
#pragma pack(push, 4)

    struct AccountConfig {
        std::string name;
        std::string email;
        std::string encrypted_password; // To be used with OpenSSL
        uint32_t character_index{ 0 };
        bool auto_login{ false };
    };

    struct AppConfig {
        std::string gw_path;
        uint32_t max_workers{ 30 };
        bool minimized_to_tray{ true };
        std::vector<AccountConfig> accounts;
    };

#pragma pack(pop)
}

// Register with Glaze for JSON support
template <>
struct glz::meta<potato::models::AppConfig> {
    using T = potato::models::AppConfig;
    static constexpr auto value = object(
        "gw_path", &T::gw_path,
        "max_workers", &T::max_workers,
        "minimized_to_tray", &T::minimized_to_tray,
        "accounts", &T::accounts
    );
};