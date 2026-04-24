#pragma once

#include <chrono>
#include <condition_variable>
#include <deque>
#include <mutex>
#include <stop_token>

namespace projectpotato::services {

template <typename T>
class ThreadSafeQueue final {
public:
    void push(const T& value) {
        {
            std::scoped_lock<std::mutex> lock(mutex_);
            queue_.push_back(value);
        }
        condition_.notify_one();
    }

    void push(T&& value) {
        {
            std::scoped_lock<std::mutex> lock(mutex_);
            queue_.push_back(std::move(value));
        }
        condition_.notify_one();
    }

    bool waitPopFor(T& value,
        const std::chrono::milliseconds timeout,
        std::stop_token stopToken) {
        std::unique_lock<std::mutex> lock(mutex_);
        const bool hasValue = condition_.wait_for(
            lock,
            stopToken,
            timeout,
            [this]() {
                return !queue_.empty();
            });

        if (!hasValue || queue_.empty()) {
            return false;
        }

        value = std::move(queue_.front());
        queue_.pop_front();
        return true;
    }

    bool empty() const {
        std::scoped_lock<std::mutex> lock(mutex_);
        return queue_.empty();
    }

    void notifyAll() {
        condition_.notify_all();
    }

private:
    mutable std::mutex mutex_;
    std::condition_variable_any condition_;
    std::deque<T> queue_;
};

} // namespace projectpotato::services
