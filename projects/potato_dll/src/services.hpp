#pragma once
#include <string>
#include <vector>
#include <memory>

namespace potato::services {

    enum class ServiceStatus { Stopped, Running, Error };

    class IService {
    public:
        virtual ~IService() = default;
        virtual void start() = 0;
        virtual void stop() = 0;
        virtual ServiceStatus get_status() const = 0;
        virtual std::string get_name() const = 0;
    };

    // A generic stub for Phase 1
    class StubService : public IService {
        std::string name;
        ServiceStatus status{ ServiceStatus::Stopped };
    public:
        StubService(std::string n) : name(std::move(n)) {}
        void start() override { status = ServiceStatus::Running; }
        void stop() override { status = ServiceStatus::Stopped; }
        ServiceStatus get_status() const override { return status; }
        std::string get_name() const override { return name; }
    };
}