/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2019  Mark Samman <mark.samman@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "otpch.h"

#include "tasks.h"
#include "game.h"

extern Game g_game;

void Dispatcher::threadMain()
{
	io_context.run();
	g_database.disconnect();
}

void Dispatcher::addTask(std::function<void (void)> functor)
{
	#if BOOST_VERSION >= 106600
	boost::asio::post(io_context,
	#else
	io_context.post(
	#endif
	#ifdef __cpp_generic_lambdas
	[this, f = std::move(functor)]() {
		++dispatcherCycle;

		// execute it
		(f)();
	});
	#else
	[this, functor]() {
		++dispatcherCycle;

		// execute it
		(functor)();
	});
	#endif
}

uint64_t Dispatcher::addEvent(uint32_t delay, std::function<void (void)> functor)
{
	if (getState() == THREAD_STATE_TERMINATED) {
		return 0;
	}

	uint64_t eventId = ++lastEventId;
	auto timer = std::make_unique<boost::asio::deadline_timer>(io_context);
	auto* timerPtr = timer.get();
	auto res = eventIds.emplace(eventId, std::move(timer));

	timerPtr->expires_from_now(boost::posix_time::milliseconds(delay));
	#ifdef __cpp_generic_lambdas
	timerPtr->async_wait([this, eventId, f = std::move(functor)](const boost::system::error_code& error) {
	#else
	timerPtr->async_wait([this, eventId, functor](const boost::system::error_code& error) {
	#endif
		// CRITICAL: Extract and erase the timer from the map BEFORE executing the functor.
		// This prevents a race condition where the functor might call stopEvent() or
		// otherwise modify eventIds, which would invalidate iterators and corrupt the map.
		std::unique_ptr<boost::asio::deadline_timer> timerGuard;
		{
			auto it = eventIds.find(eventId);
			if (it != eventIds.end()) {
				timerGuard = std::move(it->second);
				eventIds.erase(it);
			}
		}

		if (error == boost::asio::error::operation_aborted || getState() == THREAD_STATE_TERMINATED) {
			return;
		}

		// execute it
		++dispatcherCycle;
		#ifdef __cpp_generic_lambdas
		(f)();
		#else
		(functor)();
		#endif
		// timerGuard goes out of scope here, destroying the timer safely
	});

	return eventId;
}

void Dispatcher::stopEvent(uint64_t eventId)
{
	auto it = eventIds.find(eventId);
	if (it != eventIds.end()) {
		it->second->cancel();
	}
}

void Dispatcher::shutdown()
{
	setState(THREAD_STATE_TERMINATED);
	#if BOOST_VERSION >= 106600
	boost::asio::post(io_context,
	#else
	io_context.post(
	#endif
	[this]() {
		for (auto& it : eventIds) {
			it.second->cancel();
		}

		work.reset();
	});
}
